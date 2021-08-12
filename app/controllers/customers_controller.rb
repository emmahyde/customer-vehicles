class CustomersController < ApplicationController
  def index
    customer = Customer.all
    render json: customer
  end

  def show
    customer = Customer.find(customer_params[:id])
    render json: customer

  rescue ActiveRecord::RecordNotFound => e
    render json: { "error" => e.message }
  end

  def create
    customer = Customer.create!(customer_params)
    render json: customer

  rescue ActiveRecord::RecordInvalid => e
    render json: { "error" => e.message }
  end

  def update
    customer = Customer.update!(customer_params)
    render json: customer

  rescue ActiveRecord::RecordNotFound => e
    render json: { "error" => e.message }
  rescue ActiveRecord::RecordInvalid => e
    render json: { "error" => e.message }
  end

  def delete
    customer = Customer.delete!(customer_params)
    render json: customer

  rescue ActiveRecord::RecordNotFound => e
    render json: { "error" => e.message }
  end

  private

  def customer_params
    params.permit(
      :id,
      :first_name,
      :last_name,
      :email
    )
  end
end
