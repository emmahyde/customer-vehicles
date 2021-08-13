require 'rails_helper'

describe CustomersController, type: :request do
  let(:invalid_id) { 99999999999 }

  before do
    Customer.file_create(double(tempfile: fixture_path + '/commas.txt'))
  end

  describe 'GET /' do
    it 'fetches all customers' do
      get '/customers'
      expect(response.body).to eq Customer.all.to_json
    end

    context 'with sort_by and order parameters' do
      context 'when sort_by = name' do
        it 'sorts by order = ASC' do
          get '/customers', params: { sort_by: 'name', order: 'ASC' }
          expect(response.body).to eq Customer.order('name ASC').to_json
        end

        it 'sorts by order = DESC' do
          get '/customers', params: { sort_by: 'name', order: 'DESC' }
          expect(response.body).to eq Customer.order('name DESC').to_json
        end
      end
      context 'when sort_by = type' do
        it 'sorts by order = ASC' do
          get '/customers', params: { sort_by: 'type', order: 'ASC' }
          expect(response.body).to eq Customer
            .joins(:vehicles)
            .where('vehicles.primary = true')
            .order('vehicles.vehicle_type ASC')
            .to_json
        end
        it 'sorts by order = DESC' do
          get '/customers', params: { sort_by: 'type', order: 'DESC' }
          expect(response.body).to eq Customer
            .joins(:vehicles)
            .where('vehicles.primary = true')
            .order('vehicles.vehicle_type DESC')
            .to_json
        end
      end
    end
  end

  describe 'GET /:id' do
    it 'fetches 1 customer' do
      customer = Customer.all.first
      id = customer.id
      get "/customers/#{id}"
      expect(response.body).to eq customer.to_json
    end

    it 'returns an error if id does not exist' do
      get "/customers/#{invalid_id}"
      expect(response.body).to eq "{\"error\":\"Couldn't find Customer with 'id'=#{invalid_id}\"}"
    end
  end

  describe 'POST /' do
    context 'with file' do
      it 'returns the created customers with vehicles' do
        post "/customers", params: {
          file: fixture_path + '/pipes.txt'
        }
        expect(response.body).to eq Customer.where(
          email: ['a@adams.com', 'steve@crocodiles.com', 'isatou@recycle.com', 'n.uemura@gmail.com']
        ).to_json
      end
    end

    context 'with json' do
      it 'returns the created customer' do
        post "/customers", params: {
          customer: {
            first_name: 'Derby',
            last_name: 'Jones',
            email: 'derbyjones@nullmailer.com'
          }
        }
        customer = Customer.find_by(email: 'derbyjones@nullmailer.com')
        expect(response.body).to eq customer.to_json
      end
    end
  end

  describe 'PUT /:id' do
    it 'updates the customer' do
      customer = Customer.all.first
      id = customer.id
      put "/customers/#{id}", params: {
        customer: {
          first_name: 'Derby',
          last_name: 'Dingus'
        }
      }
      expect(response.body).to eq customer.reload.to_json
    end

    it 'returns an error if id does not exist' do
      put "/customers/#{invalid_id}", params: {
        customer: {
          first_name: 'Derby',
          last_name: 'Dingus'
        }
      }
      expect(response.body).to eq "{\"error\":\"Couldn't find Customer with 'id'=#{invalid_id}\"}"
    end
  end

  describe 'DELETE /:id' do
    it 'deletes the customer' do
      customer = Customer.all.first
      id = customer.id
      delete "/customers/#{id}"
      expect(response.body).to eq customer.to_json
    end

    it 'returns an error if id does not exist' do
      delete "/customers/#{invalid_id}"
      expect(response.body).to eq "{\"error\":\"Couldn't find Customer with 'id'=#{invalid_id}\"}"
    end
  end
end
