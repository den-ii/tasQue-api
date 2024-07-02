class Api::V1::AuthController < ApplicationController
  before_action :find_user, only: %i[create]

  def index
    render html: "Authentication Routes"
  end

  def create
    return if check
    puts user_params[:phone_no]
    @otp = Otp.find_by(phone_no: user_params[:phone_no])
    puts @otp
    if @otp && @otp.verified
      @user = User.new(user_params)
      if @user.save
        render json: {data: "user created", status: :created}
      else
        render json: {data: @user.errors, status: :unprocessable_entity}
      end
    else
      render json: {data: "otp not verified", status: :unprocessable_entity}
    end
  end

  def sign_in
    @user = find_user  
    if @user
      render json: {data: @user.as_json(except: [:id, :created_at, :updated_at]), status: :ok}
    else
      render json: {data: "user not found", status: :not_found}
    end
  end

  def check_user
    @user = find_user
    if @user
      render json: {data: "user already exists", status: :conflict}
    else
      Otp.create(phone_no: params[:phone_no])
      render json: {data: "user can be created", status: :ok}
    end
    
  end

  def check
    @user = find_user
    if @user
      render json: {data: "user already exists", status: :conflict}
      return true
    end
    false
  end

  def check_otp
    if params[:otp] == "43125"
      @otp = Otp.find(params[:phone_no])
      @otp.update(verified: true)
      @otp.save
      render json: {data: "otp verified", status: :ok}
    else
      render json: {data: "otp not verified", status: :unprocessable_entity}
    end
  end

  private

  def find_user
    user = User.find_by(phone_no: params[:phone_no])
    return user
  end

  def user_params
    params.require(:user).permit(:firstname, :surname, :phone_no, :country_code, :country, :state)
  end

end