require 'spec_helper'
require 'web_mock'
# Uncomment to use VCR
require 'vcr_helper'

require File.dirname(__FILE__) + '/../app/bot_client'

def stub_get_updates(token, message_text)
  body = { "ok": true, "result": [{ "update_id": 693_981_718,
                                    "message": { "message_id": 11,
                                                 "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Cliente', "last_name": 'Hambriento', "username": 'chambriento', "language_code": 'en' },
                                                 "chat": { "id": 141_733_544, "first_name": 'Cliente', "last_name": 'Hambriento', "username": 'chambriento', "type": 'private' },
                                                 "date": 1_557_782_998, "text": message_text,
                                                 "entities": [{ "offset": 0, "length": 6, "type": 'bot_command' }] } }] }

  stub_request(:any, "https://api.telegram.org/bot#{token}/getUpdates")
    .to_return(body: body.to_json, status: 200, headers: { 'Content-Length' => 3 })
end

def stub_send_message(token, message_text)
  body = { "ok": true,
           "result": { "message_id": 12,
                       "from": { "id": 715_612_264, "is_bot": true, "first_name": 'fiuba-memo2-prueba', "username": 'fiuba_memo2_bot' },
                       "chat": { "id": 141_733_544, "first_name": 'Cliente', "last_name": 'Hambriento', "username": 'chambriento', "type": 'private' },
                       "date": 1_557_782_999, "text": message_text } }

  stub_request(:post, "https://api.telegram.org/bot#{token}/sendMessage")
    .with(
      body: { 'chat_id' => '141733544', 'text' => message_text }
    )
    .to_return(status: 200, body: body.to_json, headers: {})
end

describe 'BotClient' do
  let(:token) { 'fake_token' }
  let(:api_client) { double }

  describe 'start' do
    it 'should get a /start message from an unregistered user and respond with a greeting' do
      stub_get_updates(token, '/start')
      stub_send_message(token, "Bienvenido al sistema de pedidos LaNona! \nPara registrarse ingresá tu domicilio y teléfono con los comandos /domicilio y /telefono")

      app = BotClient.new(api_client, token)

      app.run_once
    end
  end

  describe 'registration' do
    it 'should get a /registrar message with valid parameters and return a success message' do
      expect(api_client).to receive(:register).with('chambriento', 'Cucha Cucha 1234 1 Piso B', '4123-4123')

      stub_get_updates(token, '/register Cucha Cucha 1234 1 Piso B@4123-4123')
      stub_send_message(token, 'registracion exitosa')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registrar message with only one parameter and return an invalid format message' do
      stub_get_updates(token, '/register Cucha Cucha 1234 1 Piso B 4123-4123')
      stub_send_message(token, 'registracion fallida, formato invalido (separar direccion y telefono con @)')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registrar message with invalid phone and return an error message' do
      allow(api_client).to receive(:register).with('chambriento', 'Cucha Cucha 1234 1 Piso B', '').and_raise('telefono invalido')

      stub_get_updates(token, '/register Cucha Cucha 1234 1 Piso B@')
      stub_send_message(token, 'registracion fallida, telefono invalido')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registrar message with invalid address and return an error message' do
      allow(api_client).to receive(:register).with('chambriento', '', '4123-4123').and_raise('direccion invalida')

      stub_get_updates(token, '/register @4123-4123')
      stub_send_message(token, 'registracion fallida, direccion invalida')

      app = BotClient.new(api_client, token)

      app.run_once
    end
  end
end
