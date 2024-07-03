class Api::V1::AuthController < ApplicationController
  before_action :find_user, only: %i[check_user check]
  before_action :retrieve_secrets, only: %i[check_otp]
  before_action :authenticate_signin, only: %i[sign_in]
  before_action :authenticate_signup, only: %i[create]
 

  def index
    render html: "Authentication Routes"
  end

  def create
    if @current_user
        token = generate_signin_jwt(@current_user)
        render json: {data: {token: token, message: "otp verified"}, status: true}, status: :created
    else
      render json: {data: "something went wrong", errors: @user.errors, status: false}, status: :unprocessable_entity
    end
  end

  # protected with jwt 
  def sign_in
    if @current_user
      token = generate_signin_jwt(@current_user)
      render json: {data: {token: token, message: "otp verified"}, status: true}, status: :ok
    else
      render json: {data: "user not found", status: false}, status: :not_found
    end
  end

  def check_user
    if @user
      render json: {data: "user already exists", status: false}, status: :conflict
    else
      # MVP -> use bycrypt to hash random otp, then save to db
      Otp.create(phone_no: params[:phone_no])
      render json: {data: "user can be created", status: true}, status: :ok
    end
    
  end

  def check
    if @user
      render json: {data: "user already exists", status: false }, status: :conflict
      return true
    end
    false
  end

  def check_otp
    if params[:otp] == "43125"
      @otp = Otp.where(phone_no: params[:phone_no]).order(created_at: :desc).first
      return render json: {data: "user not found", status: false}, status: :not_found if !@otp
      @otp.update(verified: true)
      if @otp.save
        # send otp jwt
        payload = {data: {phone_no: params[:phone_no], message: "otp verified"}}
        token = JWT.encode payload, @secret, @encryption
        render json: {data: {token: token, message: "otp verified"}, status: true}, status: :ok
      else 
        render json: {data: "something went wrong", errors: @otp.errors, status: false }, status: :unprocessable_entity
      end
    else
      render json: {data: "otp not verified", status: false}, status: :unprocessable_entity
    end
  end

  private

  def find_user
    @user = User.find_by(phone_no: params[:phone_no])
  end

  def user_params
    params.require(:user).permit(:firstname, :surname, :phone_no, :country_code, :country, :state)
  end

  def authenticate_otp(action)
    auth_header = request.headers['Authorization']
    if auth_header.present? && auth_header =~ /^Bearer /
      payload = auth_header.split(' ').last
      p "payload: #{payload}"
      begin
        retrieve_secrets
        data = JWT.decode(payload, @secret, true, { :algorithm => @encryption }).first
        token = data["data"]
        if action == "sign_in"
          @current_user = User.find_by(phone_no: token["phone_no"])
          p "@current_user: #{@current_user}"
        elsif action == "sign_up"
         user = User.find_by(phone_no: token["phone_no"])
         return render json: {data: "user exists", status: false}, status: :conflict if user
         @current_user = User.new(user_params)
         return render json: {data: 'something went wrong', status: false}, status: :unprocessable_entity unless @current_user.save
        end
        render json: {data: 'unauthorized', status: false}, status: :unauthorized unless @current_user
      rescue JWT::DecodeError
        render json: { data: 'invalid token', status: false }, status: :unauthorized
      end
    else
      render json: { data: 'Unauthorized', status: false }, status: :unauthorized
    end
  end

  def authenticate_signup()
    authenticate_otp("sign_up")
  end

  def authenticate_signin()
    authenticate_otp("sign_in")
  end

  def retrieve_secrets
    @secret = ENV["OTP_JWT_SECRET"]      
    @encryption = ENV["JWT_ENCRYPTION"]
  end

  def generate_signin_jwt(payload)
    JWT.encode payload, @secret, @encryption
  end

end