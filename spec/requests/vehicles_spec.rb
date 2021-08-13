require 'rails_helper'

describe VehiclesController, type: :request do
  let(:invalid_id) { 99999999999 }

  before do
    Customer.file_create(double(tempfile: fixture_path + '/commas.txt'))
  end

  describe 'GET /' do
    it 'fetches all vehicles' do
      get '/vehicles'
      expect(response.body).to eq Vehicle.all.to_json
    end
  end

  describe 'GET /:id' do
    it 'fetches 1 vehicle' do
      vehicle = Vehicle.all.first
      id = vehicle.id
      get "/vehicles/#{id}"
      expect(response.body).to eq vehicle.to_json
    end

    it 'returns an error if id does not exist' do
      get "/vehicles/#{invalid_id}"
      expect(response.body).to eq "{\"error\":\"Couldn't find Vehicle with 'id'=#{invalid_id}\"}"
    end
  end

  describe 'POST /' do
    context 'with json' do
      it 'returns the created vehicle' do
        post "/vehicles", params: {
          vehicle: {
            type: 'ship',
            name: 'St. Derby Jones',
            length: 44,
            customer_id: Customer.all.first.id
          }
        }
        vehicle = Vehicle.find_by(name: 'St. Derby Jones')
        expect(response.body).to eq vehicle.to_json
      end
    end
  end

  describe 'PUT /:id' do
    it 'updates the vehicle' do
      vehicle = Vehicle.all.first
      id = vehicle.id
      put "/vehicles/#{id}", params: {
        vehicle: {
          name: 'St. Derby Jones'
        }
      }
      expect(response.body).to eq vehicle.reload.to_json
    end

    it 'returns an error if id does not exist' do
      put "/vehicles/#{invalid_id}", params: {
        vehicle: {
          name: 'St. Derby Jones'
        }
      }
      expect(response.body).to eq "{\"error\":\"Couldn't find Vehicle with 'id'=#{invalid_id}\"}"
    end
  end

  describe 'DELETE /:id' do
    it 'deletes the vehicle' do
      vehicle = Vehicle.all.first
      id = vehicle.id
      delete "/vehicles/#{id}"
      expect(response.body).to eq vehicle.to_json
    end

    it 'returns an error if id does not exist' do
      delete "/vehicles/#{invalid_id}"
      expect(response.body).to eq "{\"error\":\"Couldn't find Vehicle with 'id'=#{invalid_id}\"}"
    end
  end
end
