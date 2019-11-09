require 'spec_helper'
require 'web_mock'

require File.dirname(__FILE__) + '/../app/api_client'

describe 'ApiClient' do
  let(:client) { ApiClient.new('http://base_url') }

  describe 'registration' do
    it 'registers a valid client and obtains a client id' do
      id = client.register('chambriento', 'Cucha Cucha 1234 1 Piso B', '4123-4123')

      expect(id).to eq(1)
    end
  end
end
