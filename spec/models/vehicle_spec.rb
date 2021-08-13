require 'rails_helper'

describe Vehicle, type: :model do
  let!(:customer) do
    Customer.create!({
      first_name: 'Emma',
      last_name: 'Hyde',
      email: 'ehyde@null.com'
    })
  end

  context 'when creating a vehicle' do
    it 'cast type to vehicle_type' do
      expect {
        Vehicle.create!(
          type: 'steamboat',
          name: 'lollerroller',
          length: 1,
          customer_id: customer.id
        )
      }.to make_database_queries(
        matching: /INSERT INTO "vehicles".*vehicle_type.*/
      )
      expect(Vehicle.find_by(customer_id: customer.id).type).to eq 'steamboat'
    end

    it 'sets primary to true if it is the first vehicle for the customer' do
      Vehicle.create!(
        type: 'steamboat',
        name: 'lollerroller',
        length: 1,
        customer_id: customer.id
      )
      expect(Vehicle.find_by(customer_id: customer.id).primary).to be true
    end
  end
end
