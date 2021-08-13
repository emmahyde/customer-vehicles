class Vehicle < ApplicationRecord
  attribute :id,           :integer
  attribute :vehicle_type, :string
  attribute :name,         :string
  attribute :length,       :integer
  attribute :primary,      :boolean
  attribute :customer_id,  :integer

  alias_attribute :type, :vehicle_type
  validates  :vehicle_type, :name, :length, :customer_id, presence: true
  belongs_to :customer


  def attributes
    {
      id: id,
      type: type,
      name: name,
      length: length,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  def initialize(params)
    params[:vehicle_type] = params[:type].downcase
    params[:name]         = params[:name].titleize

    if Customer.find(params[:customer_id]).vehicles.size == 0
      params[:primary] = true
    end

    super(params.except(:type))
  end
end
