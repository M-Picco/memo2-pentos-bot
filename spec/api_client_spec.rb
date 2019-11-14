require 'spec_helper'
require 'web_mock'

require File.dirname(__FILE__) + '/../app/api_client'

def stub_req(url, body, ret_body, code)
  stub_request(:post, url)
    .with(
      body: body, headers: { 'Content-Type' => 'application/json' }
    )
    .to_return(body: ret_body, status: code)
end

def stub_success_get(url, ret_body)
  stub_request(:get, url)
    .to_return(body: ret_body.to_json, status: 200)
end

def stub_failed_get(url, error_message)
  stub_request(:get, url)
    .to_return(body: { error: error_message }.to_json, status: 400)
end

def stub_success_post(url, body, ret_body)
  stub_req(url, body.to_json, ret_body.to_json, 200)
end

def stub_failed_post(url, body, error_message)
  stub_req(url, body.to_json, { error: error_message }.to_json, 400)
end

def stub_server_error_post(url, body)
  stub_req(url, body.to_json, {}.to_json, 500)
end

describe 'ApiClient' do
  let(:base_url) { 'http://base_url' }
  let(:client) { ApiClient.new(base_url) }

  def endpoint(route)
    "#{base_url}#{route}"
  end

  describe 'registration' do
    it 'registers a valid client and obtains a client id' do
      params = { username: 'chambriento', address: 'Cucha Cucha 1234 1 Piso B', phone: '4123-4123' }

      response = { client_id: 1 }

      stub_success_post(endpoint('/client'), params, response)

      id = client.register(params[:username], params[:address], params[:phone])

      expect(id).to eq(1)
    end

    it 'fails to register a client due to invalid address' do
      params = { username: 'chambriento', address: '', phone: '4123-4123' }

      stub_failed_post(endpoint('/client'), params, 'invalid_address')

      expect { client.register(params[:username], params[:address], params[:phone]) }
        .to raise_error('Dirección inválida')
    end

    it 'fails to register a client due to invalid phone' do
      params = { username: 'chambriento', address: 'Cucha Cucha 1234 1 Piso B', phone: '' }

      stub_failed_post(endpoint('/client'), params, 'invalid_phone')

      expect { client.register(params[:username], params[:address], params[:phone]) }
        .to raise_error('Teléfono inválido')
    end

    it 'fails to register a client due to invalid username' do
      params = { username: '', address: 'Cucha Cucha 1234 1 Piso B', phone: '4123-4123' }

      stub_failed_post(endpoint('/client'), params, 'invalid_username')

      expect { client.register(params[:username], params[:address], params[:phone]) }
        .to raise_error('Usuario inválido')
    end

    it 'fails to register a client due to server side error' do
      params = { username: 'chambriento', address: 'Cucha Cucha 1234 1 Piso B', phone: '4123-4123' }

      stub_server_error_post(endpoint('/client'), params)

      expect { client.register(params[:username], params[:address], params[:phone]) }
        .to raise_error('Error del servidor, espere y vuelva a intentarlo')
    end
  end

  describe 'order' do
    it 'register client orders and obtains a order id' do
      username = 'pepito_p'
      response = { order_id: 1 }

      stub_success_post(endpoint("/client/#{username}/order"), {}, response)
      id = client.order(username)

      expect(id).to eq(1)
    end

    it 'fails to order due to server side error' do
      username = 'pepito_p'

      stub_server_error_post(endpoint("/client/#{username}/order"), {})

      expect { client.order(username) }
        .to raise_error('Error del servidor, espere y vuelva a intentarlo')
    end
  end

  describe 'order status' do
    # rubocop:disable RSpec/ExampleLength
    it 'registered client ask for order id status and obtains "ha sido RECIBIDO"' do
      username = 'pepito_p'
      order_id = 1
      response = { order_status: 'recibido' }

      stub_success_get(endpoint("/client/#{username}/order/#{order_id}"), response)

      order_status = client.order_status(username, order_id)

      expect(order_status).to eq('ha sido RECIBIDO')
    end

    it 'registered client ask for order id status and obtains "esta EN PREPARACION"' do
      username = 'pepito_p'
      order_id = 1
      response = { order_status: 'en_preparacion' }

      stub_success_get(endpoint("/client/#{username}/order/#{order_id}"), response)

      order_status = client.order_status(username, order_id)

      expect(order_status).to eq('esta EN PREPARACION')
    end
    # rubocop:enable RSpec/ExampleLength

    it 'registered client ask for non existent order id status and fails' do
      username = 'pepito_p'
      order_id = 500

      stub_failed_get(endpoint("/client/#{username}/order/#{order_id}"), 'order not exist')

      expect { client.order_status(username, order_id) }
        .to raise_error('El pedido indicado no existe')
    end

    it 'registered client without orders ask for order id status and fails' do
      username = 'pepito_sin_ordenes'
      order_id = 2

      stub_failed_get(endpoint("/client/#{username}/order/#{order_id}"), 'there are no orders')

      expect { client.order_status(username, order_id) }
        .to raise_error('Todavía no has realizado pedidos')
    end
  end

  describe 'order rate' do
    # rubocop:disable RSpec/ExampleLength:
    it 'rates a delivered order' do
      username = 'pepito_p'
      order_id = 2

      params = { rating: 4 }
      response = { rating: 4 }

      stub_success_post(endpoint("/client/#{username}/order/#{order_id}/rate"), params, response)

      res = client.order_rate(username, order_id, params[:rating])

      expect(res).to eq(4)
    end
    # rubocop:enable RSpec/ExampleLength:
  end
end
