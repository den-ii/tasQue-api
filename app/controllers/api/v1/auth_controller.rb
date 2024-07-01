class Api::V1::AuthController < ApplicationController
  before_action :find_user, only: %i[create]

  def index
    render html: "Authentication Routes"
  end


  def create
    return if check
    @user = User.new(user_params)
    if @user.save
      render json: {data: "user created", status: :created}
    else
      render json: {data: @user.errors, status: :unprocessable_entity}
    end
  end

  def sign_in
    @user = find_user
    if @user
      render json: {data: @user, status: :ok}
    else
      render json: {data: "user not found", status: :not_found}
    end
  end

  def check_user
    @user = find_user
    if @user
      render json: {data: "user already exists", status: :conflict}
    else 
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

  private

  def find_user
    user = User.find_by(phone_no: params[:phone_no])
    return user
  end

  def user_params
    params.require(:user).permit(:firstname, :surname, :phone_no, :country_code, :country, :state)
  end

end