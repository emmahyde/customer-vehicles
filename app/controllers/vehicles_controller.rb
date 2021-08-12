class VehiclesController < ApplicationController
  def index
    vehicle = Vehicle.all
    render json: vehicle
  end

  def show
    vehicle = Vehicle.find(vehicle_params[:id])
    render json: vehicle

  rescue ActiveRecord::RecordNotFound => e
    render json: { "error" => e.message }
  end

  def create
    vehicle = Vehicle.create!(vehicle_params)
    render json: vehicle

  rescue ActiveRecord::RecordInvalid => e
    render json: { "error" => e.message }
  end

  def update
    vehicle = Vehicle.update!(vehicle_params)
    render json: vehicle

  rescue ActiveRecord::RecordNotFound => e
    render json: { "error" => e.message }
  rescue ActiveRecord::RecordInvalid => e
    render json: { "error" => e.message }
  end

  def delete
    vehicle = Vehicle.delete!(vehicle_params)
    render json: vehicle

  rescue ActiveRecord::RecordNotFound => e
    render json: { "error" => e.message }
  end

  private

  def vehicle_params
    params.permit(
      :id,
      :type,
      :name,
      :length
    )
  end
end
