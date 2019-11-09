class ApiClient
  ERRORS = {
    'invalid_username' => 'usuario invalido',
    'invalid_address' => 'direccion invalida',
    'invalid_phone' => 'telefono invalido',
    'server_error' => 'error del servidor, espere y vuelva a intentarlo'
  }.freeze

  def initialize(api_base_url)
    @api_base_url = api_base_url
  end

  def register(username, address, phone)
    params = {
      username: username,
      address: address,
      phone: phone
    }

    response = Faraday.post(endpoint('/client'), params.to_json, 'Content-Type' => 'application/json')
    body = JSON.parse(response.body)

    raise parse_error(body['error']) if response.status == 403
    raise parse_error('server_error') if response.status == 500

    body['client_id']
  end

  private

  def parse_error(error_message)
    ERRORS[error_message]
  end

  def endpoint(route)
    "#{@api_base_url}#{route}"
  end
end
