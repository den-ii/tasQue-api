class Api::V1::AuthController < ApplicationController
  before_action :find_user, only: %i[check_user]
  before_action :retrieve_secrets, only: %i[verify_otp]
  before_action :authenticate_signin, only: %i[sign_in]
  before_action :authenticate_signup, only: %i[create]
  before_action :authenticate_jwt, only: %i[modify_location]
 

  def index
    render html: "Authentication Routes"
  end

  def create
    if @current_user
        token = generate_signin_jwt(@current_user.to_json)
        render json: {data: {token: token, message: "otp verified"}, status: true}, status: :created
    end
  end

  # protected with jwt 
  def sign_in
    if @current_user
      token = generate_signin_jwt(@current_user.to_json)
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

  def generate_otp
      # MVP -> use bycrypt to hash random otp, then save to db
    Otp.create(phone_no: params[:phone_no])
    render json: {data: "otp generated", status: true}, status: :ok  
  end

  def modify_location
    p "api: #{params[:location]}"
    return if !@current_user 
    response = HTTParty.get('http://api.positionstack.com/v1/reverse', 
    query: { 
        access_key: ENV['POSITION_STACK_API_KEY'], 
        query: params[:location], 
        output: 'json'
    })
    data = JSON.parse(response.body)["data"][0]
    country = data["country"]
    city = data["region"]
    @current_user.update(country: country, city: city)    
    return render json: {data: "location updated", status: true}
  end


  def verify_otp
    if params[:otp] == "431256"
      @otp = Otp.where(phone_no: params[:phone_no]).order(created_at: :desc).first
      return render json: {data: "user not found", status: false}, status: :not_found if !@otp
      @otp.update(verified: true)
      if @otp.save
        # send otp jwt
        payload = {data: {phone_no: params[:phone_no], message: "otp verified"}}
        token = JWT.encode payload, @secret, @encryption
        if @user
         render json: {data: {token: token, message: "otp verified", state: "login"}, status: true}, status: :ok
        else
         render json: {data: {token: token, message: "otp verified", state: "signup"}, status: true}, status: :ok
        end
      else 
        render json: {data: "otp not verified", status: false}, status: :unprocessable_entity
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
    params.require(:user).permit(:firstname, :surname, :phone_no,)
  end

  def create_user_params
     params.permit(:firstname, :surname, :phone_no, :avatar, :dob)
  end

  def authenticate_otp(action)
    auth_header = request.headers['Authorization']
    if auth_header.present? && auth_header =~ /^Bearer /
      payload = auth_header.split(' ').last
      begin
        retrieve_secrets
        data = JWT.decode(payload, @secret, true, { :algorithm => @encryption }).first
        token = data["data"]
        if action == "sign_in"
          @current_user = User.find_by(phone_no: token["phone_no"])
        elsif action == "sign_up"
         user = User.find_by(phone_no: token["phone_no"])
         return render json: {data: "user exists", status: false}, status: :conflict if user

         p "user_params: #{params}"
         @current_user = User.new(firstname: params[:firstname], surname: params[:surname], phone_no: token["phone_no"], dob: params[:dob])
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

  def authenticate_jwt
    auth_header = request.headers['Authorization']
    if auth_header.present? && auth_header =~ /^Bearer /
      payload = auth_header.split(' ').last
      begin
        retrieve_secrets
        data = JWT.decode(payload, @secret, true, { :algorithm => @encryption }).first
        data = data["data"]
        p("data: #{data["phone_no"]}")
        @current_user = User.find_by(phone_no: data["phone_no"])
        p @current_user.firstname
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