require 'spec_helper'
require 'web_mock'
# Uncomment to use VCR
require 'vcr_helper'

require File.dirname(__FILE__) + '/../app/bot_client'

def stub_get_updates(token, message_text, null_username = false)
  username = null_username ? nil : 'chambriento'

  body = { "ok": true, "result": [{ "update_id": 693_981_718,
                                    "message": { "message_id": 11,
                                                 "from": { "id": 141_733_544, "is_bot": false, "first_name": 'Cliente', "last_name": 'Hambriento', "username": username, "language_code": 'en' },
                                                 "chat": { "id": 141_733_544, "first_name": 'Cliente', "last_name": 'Hambriento', "username": username, "type": 'private' },
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
      stub_send_message(token, "Bienvenido al sistema de pedidos LaNona! \nPara registrarse ingresá /registracion {tu_domicilio},{tu_telefono}")

      app = BotClient.new(api_client, token)

      app.run_once
    end
  end

  describe 'stop' do
    it 'should get a /stop message from an unregistered user and respond with a goodbye message' do
      stub_get_updates(token, '/stop')
      stub_send_message(token, 'Gracias por usar el sistema de pedidos LaNona!')

      app = BotClient.new(api_client, token)

      app.run_once
    end
  end

  describe 'registration' do
    it 'should get a /registracion message with valid parameters and return a success message' do
      expect(api_client).to receive(:register).with('chambriento', 'Cucha Cucha 1234 1 Piso B', '4123-4123')

      stub_get_updates(token, '/registracion Cucha Cucha 1234 1 Piso B,4123-4123')
      stub_send_message(token, 'Registracion exitosa')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registracion message with only one parameter and return an invalid format message' do
      stub_get_updates(token, '/registracion Cucha Cucha 1234 1 Piso B 4123-4123')
      stub_send_message(token, 'Registracion fallida: Formato invalido (separar direccion y telefono con ,)')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registracion message with invalid phone and return an error message' do
      allow(api_client).to receive(:register).with('chambriento', 'Cucha Cucha 1234 1 Piso B', '').and_raise('Telefono invalido')

      stub_get_updates(token, '/registracion Cucha Cucha 1234 1 Piso B,')
      stub_send_message(token, 'Registracion fallida: Telefono invalido')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registracion message with null username and return an error message' do
      expect(api_client).to receive(:register).with('', 'Cucha Cucha 1234 1 Piso B', '4123-4123').and_raise('Usuario invalido')

      stub_get_updates(token, '/registracion Cucha Cucha 1234 1 Piso B,4123-4123', null_username: true)
      stub_send_message(token, 'Registracion fallida: Usuario invalido')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registracion message with invalid address and return an error message' do
      allow(api_client).to receive(:register).with('chambriento', '', '4123-4123').and_raise('Direccion invalida')

      stub_get_updates(token, '/registracion ,4123-4123')
      stub_send_message(token, 'Registracion fallida: Direccion invalida')

      app = BotClient.new(api_client, token)

      app.run_once
    end

    it 'should get a /registracion message with valid parameters, trim them and return a success message' do
      expect(api_client).to receive(:register).with('chambriento', 'Cucha Cucha 1234 1 Piso B', '4123-4123')

      stub_get_updates(token, '/registracion   Cucha Cucha 1234 1 Piso B  ,  4123-4123  ')
      stub_send_message(token, 'Registracion exitosa')

      app = BotClient.new(api_client, token)

      app.run_once
    end
  end
end
