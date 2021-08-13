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
          get '/customers', params: { sort_by: 'full_name', order: 'ASC' }
          expect(JSON.parse(response.body).first['full_name']).to eq 'Greta Thunberg'
          expect(JSON.parse(response.body).second['full_name']).to eq 'Jimmy Buffet'
          expect(JSON.parse(response.body).third['full_name']).to eq 'Mandip Singh Soin'
          expect(JSON.parse(response.body).last['full_name']).to eq 'Xiuhtezcatl Martinez'
        end

        it 'sorts by order = DESC' do
          get '/customers', params: { sort_by: 'full_name', order: 'DESC' }
          expect(JSON.parse(response.body).first['full_name']).to eq 'Xiuhtezcatl Martinez'
          expect(JSON.parse(response.body).second['full_name']).to eq 'Mandip Singh Soin'
          expect(JSON.parse(response.body).third['full_name']).to eq 'Jimmy Buffet'
          expect(JSON.parse(response.body).last['full_name']).to eq 'Greta Thunberg'
        end
      end
      context 'when sort_by = type' do
        it 'sorts by order = ASC' do
          get '/customers', params: { sort_by: 'vehicle_type', order: 'ASC' }
          expect(JSON.parse(response.body).first['vehicle']['type']).to eq 'campervan'
          expect(JSON.parse(response.body).second['vehicle']['type']).to eq 'motorboat'
          expect(JSON.parse(response.body).third['vehicle']['type']).to eq 'sailboat'
          expect(JSON.parse(response.body).last['vehicle']['type']).to eq 'sailboat'
        end
        it 'sorts by order = DESC' do
          get '/customers', params: { sort_by: 'vehicle_type', order: 'DESC' }
          expect(JSON.parse(response.body).first['vehicle']['type']).to eq 'sailboat'
          expect(JSON.parse(response.body).second['vehicle']['type']).to eq 'sailboat'
          expect(JSON.parse(response.body).third['vehicle']['type']).to eq 'motorboat'
          expect(JSON.parse(response.body).last['vehicle']['type']).to eq 'campervan'
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
          email: %w[a@adams.com steve@crocodiles.com isatou@recycle.com n.uemura@gmail.com]
        ).to_json
      end
    end

    context 'with json' do
      it 'returns the created customer' do
        post "/customers", params: {
          customer: {
            full_name: 'Derby Jones',
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
      put "/customers/#{id}", params: { customer: { full_name: 'Derby Jones' }}
      expect(response.body).to eq customer.reload.to_json
    end

    it 'returns an error if id does not exist' do
      put "/customers/#{invalid_id}", params: { customer: { full_name: 'Derby Dingus' }}
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
