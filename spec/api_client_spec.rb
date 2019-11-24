require 'spec_helper'
require 'web_mock'

require File.dirname(__FILE__) + '/../app/api_client'

def stub_post(url, body, ret_body, code)
  stub_request(:post, url)
    .with(
      body: body, headers: { 'Content-Type' => 'application/json', 'api-key': (ENV['API_KEY'] || 'zaraza') }
    )
    .to_return(body: ret_body, status: code)
end

def stub_success_post(url, body, ret_body)
  stub_post(url, body.to_json, ret_body.to_json, 200)
end

def stub_failed_post(url, body, error_message)
  stub_post(url, body.to_json, { error: error_message }.to_json, 400)
end

def stub_server_error_post(url, body)
  stub_post(url, body.to_json, {}.to_json, 500)
end

###################################
def stub_put(url, body, ret_body, code)
  stub_request(:put, url)
    .with(
      body: body, headers: { 'Content-Type' => 'application/json', 'api-key': (ENV['API_KEY'] || 'zaraza') }
    )
    .to_return(body: ret_body, status: code)
end

def stub_success_put(url, body, ret_body)
  stub_put(url, body.to_json, ret_body.to_json, 200)
end

def stub_failed_put(url, body, error_message)
  stub_put(url, body.to_json, { error: error_message }.to_json, 400)
end

def stub_server_error_put(url, body)
  stub_put(url, body.to_json, {}.to_json, 500)
end

###################################
def stub_success_get(url, ret_body)
  stub_request(:get, url)
    .to_return(body: ret_body.to_json, status: 200)
end

def stub_failed_get(url, error_message)
  stub_request(:get, url)
    .to_return(body: { error: error_message }.to_json, status: 400)
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
    # rubocop:disable RSpec/ExampleLength
    it 'register client orders and obtains a order id' do
      username = 'pepito_p'
      params = { order: 'menu_individual' }
      response = { order_id: 1 }

      stub_success_post(endpoint("/client/#{username}/order"), params, response)
      id = client.order(username, params[:order])

      expect(id).to eq(1)
    end
    # rubocop:enable RSpec/ExampleLength

    it 'fails to order due to server side error' do
      username = 'pepito_p'
      params = { order: 'menu_individual' }

      stub_server_error_post(endpoint("/client/#{username}/order"), params)

      expect { client.order(username, params[:order]) }
        .to raise_error('Error del servidor, espere y vuelva a intentarlo')
    end
    it 'registered client orders an invalid menu' do
      username = 'pepito_p'
      params = { order: 'menu_ejecutivo' }

      stub_failed_post(endpoint("/client/#{username}/order"), params, 'invalid_menu')

      expect { client.order(username, params[:order]) }
        .to raise_error('Menú inválido')
    end

    it 'not registered client orders a valid menu' do
      username = 'pepito_p'
      params = { order: 'menu_individual' }

      stub_failed_post(endpoint("/client/#{username}/order"), params, 'not_registered')

      expect { client.order(username, params[:order]) }
        .to raise_error('Primero debes registrarte')
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

    it 'registered client ask for order id status and obtains "esta EN ESPERA"' do
      username = 'pepito_p'
      order_id = 1
      response = { order_status: 'en_espera' }

      stub_success_get(endpoint("/client/#{username}/order/#{order_id}"), response)

      order_status = client.order_status(username, order_id)

      expect(order_status).to eq('esta EN ESPERA')
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

    it 'not registered client asks for order id status and fails' do
      username = 'pepito_no_existe'
      order_id = 2

      stub_failed_get(endpoint("/client/#{username}/order/#{order_id}"), 'not_registered')

      expect { client.order_status(username, order_id) }
        .to raise_error('Primero debes registrarte')
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

    it 'fails to rate an undelivered order' do
      username = 'pepito_p'
      order_id = 2

      params = { rating: 4 }

      stub_failed_post(endpoint("/client/#{username}/order/#{order_id}/rate"), params, 'order_not_delivered')

      expect { client.order_rate(username, order_id, params[:rating]) }
        .to raise_error('El pedido solo puede calificarse una vez ENTREGADO')
    end

    it 'fails to rate an order due to invalid rating' do
      username = 'pepito_p'
      order_id = 2

      params = { rating: -14 }

      stub_failed_post(endpoint("/client/#{username}/order/#{order_id}/rate"), params, 'invalid_rating')

      expect { client.order_rate(username, order_id, params[:rating]) }
        .to raise_error("La calificación '-14' no es válida, ingresa un número entre 1 y 5")
    end

    it 'not registered user fails to rate an order' do
      username = 'pepito_p'
      order_id = 2

      params = { rating: 4 }

      stub_failed_post(endpoint("/client/#{username}/order/#{order_id}/rate"), params, 'not_registered')

      expect { client.order_rate(username, order_id, params[:rating]) }
        .to raise_error('Primero debes registrarte')
    end
    # rubocop:enable RSpec/ExampleLength:
  end

  describe 'order cancel' do
    # rubocop:disable RSpec/ExampleLength:
    it 'cancels a cancellable order' do
      username = 'pepito_p'
      order_id = 2

      params = {}
      response = {}

      stub_success_put(endpoint("/order/#{order_id}/cancel"), params, response)

      res = client.order_cancel(username, order_id)

      expect(res).to eq('Pedido cancelado con éxito')
    end

    it 'fails to cancel a no longer cancellable order' do
      username = 'pepito_p'
      order_id = 2

      params = {}

      stub_failed_put(endpoint("/order/#{order_id}/cancel"), params, 'cannot_cancel')

      expect { client.order_cancel(username, order_id) }
        .to raise_error('El pedido ya no puede cancelarse')
    end

    it 'not registered user fails to rate an order' do
      username = 'pepito_p'
      order_id = 2

      stub_failed_put(endpoint("/order/#{order_id}/cancel"), {}, 'not_registered')

      expect { client.order_cancel(username, order_id) }
        .to raise_error('Primero debes registrarte')
    end

    it 'fails to cancel due to server error' do
      username = 'pepito_p'
      order_id = 2

      stub_server_error_put(endpoint("/order/#{order_id}/cancel"), {})

      expect { client.order_cancel(username, order_id) }
        .to raise_error('Error del servidor, espere y vuelva a intentarlo')
    end
    # rubocop:enable RSpec/ExampleLength:
  end

  describe 'historical orders' do
    it 'registered client without orders ask for historical orders and obtains "No tiene pedidos"' do
      username = 'pepito_p'
      response = []

      stub_success_get(endpoint("/client/#{username}/historical"), response)

      historical_orders = client.historical_orders(username)

      expect(historical_orders).to eq('No tiene pedidos')
    end
  end
end
