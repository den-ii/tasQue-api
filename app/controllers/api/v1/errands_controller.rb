class Api::V1::ErrandsController < ApplicationController
  before_action :authenticate_jwt, only: %i[create destroy]

  def create
    p "errands params: #{errand_params}"
    p "current user: #{@current_user}"
    return if !@current_user
    errand = Errand.new(errand_params.merge(user_id: @current_user.id))

    if errand.save
      render json: { data: errand.to_json, status: true }, status: :created
    else
      render json: { data: errand.errors, status: false }, status: :unprocessable_entity
    end
  end

  def destroy
    return if !@current_user
    errand = Errand.find(params[:id])
    errand.destroy
    render json: { data: 'errand deleted', status: true }, status: :ok
  end

  private
  def errand_params
    params.require(:errand).permit(:title, :starting_point, :description, :amount)
  end
end
