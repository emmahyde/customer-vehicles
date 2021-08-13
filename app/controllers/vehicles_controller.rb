class VehiclesController < ApplicationController
  def index
    render json: Vehicle.all
  end

  def show
    render json: Vehicle.find(params[:id])

  rescue ActiveRecord::RecordNotFound => e
    render json: { "error" => e.message }
  end

  def create
    render json: Vehicle.create!(vehicle_params)

  rescue ActiveRecord::RecordInvalid => e
    render json: { "error" => e.message }
  end

  def update
    vehicle = Vehicle.find(params[:id])
    vehicle.update!(vehicle_params)
    render json: vehicle.reload

  rescue *ACTIVE_RECORD_EXS => e
    render json: { "error" => e.message }
  end

  def destroy
    vehicle = Vehicle.find(params[:id])
    vehicle.delete
    render json: vehicle

  rescue ActiveRecord::RecordNotFound => e
    render json: { "error" => e.message }
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(
      :type,
      :name,
      :length,
      :customer_id
    )
  end
end
