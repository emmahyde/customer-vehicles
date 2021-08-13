class CustomersController < ApplicationController
  SUPPORTED_SORTS = %w[full_name vehicle_type]
  CUSTOMER_EXS = [CustomerError]
  RETURNABLE_EXS = ACTIVE_RECORD_EXS + CUSTOMER_EXS

  def index
    sort_params = params.permit(:sort_by, :order)
    sort_by     = sort_params[:sort_by]
    order       = sort_params[:order]&.upcase || 'ASC'

    if SUPPORTED_SORTS.include?(sort_by)
      validated_sort(order, sort_by)
    else
      render json: Customer.all
    end

  rescue *CUSTOMER_EXS => e
    render json: { "error" => e.message }
  end

  def show
    customer = Customer.find(params[:id])
    render json: customer

  rescue ActiveRecord::RecordNotFound => e
    render json: { "error" => e.message }
  end

  def create
    file = params.permit(:file)[:file]
    if file && File.file?(file)
      emails = Customer.file_create(file)
      customers = Customer.where(email: emails)
    else
      customers = Customer.create!(customer_params)
    end
    render json: customers

  rescue *RETURNABLE_EXS => e
    render json: { "error" => e.message }
  end

  def update
    customer = Customer.find(params[:id])
    customer.update!(customer_params)
    render json: customer.reload

  rescue *RETURNABLE_EXS => e
    render json: { "error" => e.message }
  end

  def destroy
    customer = Customer.find(params[:id])
    customer.delete
    render json: customer

  rescue ActiveRecord::RecordNotFound => e
    render json: { "error" => e.message }
  end

  private

  def validated_sort(order, sort_by)
    case sort_by
    when 'full_name'
      sort_criteria = "first_name #{order}, last_name #{order}"
      render json: Customer.order(sort_criteria)

    when 'vehicle_type'
      sort_criteria = ['vehicles.vehicle_type', order].compact.join(' ')
      render json: Customer
       .joins(:vehicles)
       .where('vehicles.primary = true')
       .order(sort_criteria)

    else
      raise CustomerError, 'Input invalid: invalid sort criteria'
    end
  end

  def customer_params
    params.require(:customer).permit(
      :first_name,
      :last_name,
      :full_name,
      :email
    )
  end
end
