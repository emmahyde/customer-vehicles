require 'rails_helper'

describe Customer, type: :model do
  describe 'serialization to JSON' do
    let(:formatted_time) { DateTime.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ") }
    before { Timecop.freeze }

    context 'when a customer has no vehicles' do
      let(:customer) do
        Customer.create!({
          full_name: 'Derby Jones',
          email:     'derbyjones@nullmailer.com'
        })
      end

      it 'return customer with empty vehicle association' do
        expect(customer.attributes.to_json).to eq(
          JSON.generate({
            id:         customer.id,
            full_name:  customer.name,
            email:      customer.email,
            created_at: formatted_time,
            updated_at: formatted_time,
            vehicle:    nil
          })
        )
      end
    end

    context 'when a customer has at least one vehicle' do
      let(:customer) do
        Customer.create!({
          full_name: 'Derby Jones',
          email:     'derbyjones@nullmailer.com'
        })
      end
      let!(:vehicle_a) do
        Vehicle.create!({
          type:        'steamboat',
          name:        'St. Derby',
          length:      99,
          customer_id: customer.id,
          primary:     true
        })
      end
      let!(:vehicle_b) do
        Vehicle.create!({
          type:        'yacht',
          name:        'Big Charlie',
          length:      22,
          customer_id: customer.id
        })
      end

      it 'return customer with primary vehicle association' do
        expect(Vehicle.all.size).to eq 2
        expect(customer.attributes.to_json).to eq(
          JSON.generate({
            id:         customer.id,
            full_name:  customer.name,
            email:      customer.email,
            created_at: formatted_time,
            updated_at: formatted_time,
            vehicle:    {
              id:         vehicle_a.id,
              type:       vehicle_a.vehicle_type,
              name:       vehicle_a.name,
              length:     vehicle_a.length,
              created_at: formatted_time,
              updated_at: formatted_time,
            }
          })
        )
      end
    end
  end

  describe 'file processing' do
    let(:commas_file) { double(tempfile: fixture_path + '/commas.txt') }
    let(:pipes_file) { double(tempfile: fixture_path + '/pipes.txt') }
    let(:malformed_file) { double(tempfile: fixture_path + '/malformed.txt') }

    context 'when file is comma separated' do
      before { Customer.file_create(commas_file) }

      it 'successfully create customers and associated vehicles' do
        customer_1, c1_vehicle = get_customer_and_vehicle('greta@future.com')
        customer_2, c2_vehicle = get_customer_and_vehicle('martinez@earthguardian.org')
        customer_3, c3_vehicle = get_customer_and_vehicle('mandip@ecotourism.net')
        customer_4, c4_vehicle = get_customer_and_vehicle('jb@sailor.com')

        expect(customer_1.name).to eq 'Greta Thunberg'
        expect(customer_2.name).to eq 'Xiuhtezcatl Martinez'
        expect(customer_3.name).to eq 'Mandip Singh Soin'
        expect(customer_4.name).to eq 'Jimmy Buffet'

        expect([c1_vehicle.type, c1_vehicle.name, c1_vehicle.length]).to eq ["sailboat", "Fridays For Future", 32]
        expect([c2_vehicle.type, c2_vehicle.name, c2_vehicle.length]).to eq ["campervan", "Earth Guardian", 28]
        expect([c3_vehicle.type, c3_vehicle.name, c3_vehicle.length]).to eq ["motorboat", "Frozen Trekker", 32]
        expect([c4_vehicle.type, c4_vehicle.name, c4_vehicle.length]).to eq ["sailboat", "Margaritaville", 40]
      end
    end
    context 'when file is pipe separated' do
      before { Customer.file_create(pipes_file) }

      it 'successfully create customers and associated vehicles' do
        customer_1, c1_vehicle = get_customer_and_vehicle('a@adams.com')
        customer_2, c2_vehicle = get_customer_and_vehicle('steve@crocodiles.com')
        customer_3, c3_vehicle = get_customer_and_vehicle('isatou@recycle.com')
        customer_4, c4_vehicle = get_customer_and_vehicle('n.uemura@gmail.com')

        expect(customer_1.name).to eq 'Ansel Adams'
        expect(customer_2.name).to eq 'Steve Irwin'
        expect(customer_3.name).to eq 'Isatou Ceesay'
        expect(customer_4.name).to eq 'Naomi Uemura'

        expect([c1_vehicle.type, c1_vehicle.name, c1_vehicle.length]).to eq ["motorboat", "Rushing Water", 24]
        expect([c2_vehicle.type, c2_vehicle.name, c2_vehicle.length]).to eq ["rv", "G’day For Adventure", 32]
        expect([c3_vehicle.type, c3_vehicle.name, c3_vehicle.length]).to eq ["campervan", "Plastic To Purses", 20]
        expect([c4_vehicle.type, c4_vehicle.name, c4_vehicle.length]).to eq ["bicycle", "Glacier Glider", 5]
      end
    end
    context 'when a row is malformed' do
      it 'successfully create other, valid rows and do not throw errors' do
        expect { Customer.file_create(malformed_file) }.not_to raise_error
        customer, vehicle = get_customer_and_vehicle('valid@nullmailer.com')

        expect(Customer.all.size).to eq 1
        expect(customer.name).to eq 'Valid Customer'
        expect([vehicle.type, vehicle.name, vehicle.length]).to eq ['v_type', 'V Name', 0]
      end
    end

    def get_customer_and_vehicle(email)
      customer = Customer.find_by(email: email)
      [customer, customer.vehicle]
    end
  end

  describe 'model constraints' do
    context 'when an email is not unique' do
      before do
        Customer.create!({
          full_name: 'Derby Jones',
          email:     'derbyjones@nullmailer.com'
        })
      end

      it 'rejects the customer and raises an error' do
        expect {
          Customer.create!({
            full_name: 'Derby Jones',
            email:     'derbyjones@nullmailer.com'
          })
        }.to raise_error ActiveRecord::RecordInvalid,
          "Validation failed: Email has already been taken"
      end
    end
  end

  context 'when creating a customer' do
    it 'casts first & last name to a single name field' do
      expect {
        Customer.create!({
          full_name: 'Derby Jones',
          email:     'derbyjones@nullmailer.com'
        })
      }.to make_database_queries(
        matching: /INSERT INTO "customers".*"first_name",.*"last_name".*/
      )
      expect(Customer.find_by(email: 'derbyjones@nullmailer.com').name).to eq 'Derby Jones'
    end
  end
end
