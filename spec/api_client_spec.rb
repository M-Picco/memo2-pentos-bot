require 'spec_helper'
require 'web_mock'

require File.dirname(__FILE__) + '/../app/api_client'

def stub_success_post(url, body, ret_body)
  stub_request(:post, url)
    .with(
      body: body.to_json, headers: { 'Content-Type' => 'application/json' }
    )
    .to_return(body: ret_body.to_json, status: 200)
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
  end
end
