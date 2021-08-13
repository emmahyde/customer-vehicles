class Customer < ApplicationRecord
  attribute :id,         :integer
  attribute :first_name, :string
  attribute :last_name,  :string
  attribute :full_name,  :string
  attribute :email,      :string

  validates :email, presence: true, uniqueness: true
  validate  :name_is_present
  has_many  :vehicles
  has_one   :vehicle, -> { where(primary: true) }

  def attributes
    {
      id:         id,
      full_name:  full_name,
      email:      email,
      created_at: created_at,
      updated_at: updated_at,
      vehicle:    vehicle
    }
  end

  def full_name
    [first_name, last_name].compact.join(' ')
  end

  def full_name=(value)
    params = value.split(' ')
    assign_attributes first_name: params[0], last_name: params[1]
  end

  def name_is_present
    unless (first_name && last_name) || full_name
      errors.add(base: 'Validation failed: must have both first & last OR full_name present')
    end
  end

  alias :name :full_name
  class << self

    # file_create creates both customers
    # and a single associated vehicle from the given format
    def file_create(file)
      processed = []

      lines = if file.respond_to? :tempfile
                File.read(file.tempfile)
              elsif file.is_a? String
                File.read(file)
              end

      lines.split("\n").each do |line|
        processed << parse_customer(line)
      end

      processed
    end

    private

    SPLIT_CRITERIA = /[|,]/
    HEADER = {
      first_name: 0,
      last_name:  1,
      email:      2,
      type:       3,
      name:       4,
      length:     5
    }

    def parse_customer(line)
      params   = line.split(SPLIT_CRITERIA)
      customer = Customer.find_by(email: params[HEADER[:email]])
      primary  = false

      unless customer
        customer = Customer.create customer_file_params(params)
        primary  = true
        customer.save
      end

      if customer.valid?
        vehicle = Vehicle.create vehicle_file_params(params, customer, primary)
        vehicle.save
        customer.email
      end
    end

    def customer_file_params(params)
      {
        first_name: params[HEADER[:first_name]],
        last_name:  params[HEADER[:last_name]],
        email:      params[HEADER[:email]],
      }
    end

    def vehicle_file_params(params, customer, primary)
      {
        type:        params[HEADER[:type]],
        name:        params[HEADER[:name]],
        length:      params[HEADER[:length]],
        customer_id: customer.id,
        primary:     primary
      }
    end
  end
end
