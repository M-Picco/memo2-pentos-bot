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
        .to raise_error('Direccion invalida')
    end

    it 'fails to register a client due to invalid phone' do
      params = { username: 'chambriento', address: 'Cucha Cucha 1234 1 Piso B', phone: '' }

      stub_failed_post(endpoint('/client'), params, 'invalid_phone')

      expect { client.register(params[:username], params[:address], params[:phone]) }
        .to raise_error('Telefono invalido')
    end

    it 'fails to register a client due to invalid username' do
      params = { username: '', address: 'Cucha Cucha 1234 1 Piso B', phone: '4123-4123' }

      stub_failed_post(endpoint('/client'), params, 'invalid_username')

      expect { client.register(params[:username], params[:address], params[:phone]) }
        .to raise_error('Usuario invalido')
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

      id = client.order(username)
      expect(id).to eq(1)
    end
  end
end
