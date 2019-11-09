class ApiClient
  def initialize(api_base_url)
    @api_base_url = api_base_url
    @error_mapper = ApiErrorMapper.new
  end

  def register(username, address, phone)
    params = {
      username: username,
      address: address,
      phone: phone
    }

    response = Faraday.post(endpoint('/client'), params.to_json, 'Content-Type' => 'application/json')
    body = JSON.parse(response.body)

    raise @error_mapper.map(body['error']) if response.status == 403
    raise @error_mapper.map('server_error') if response.status == 500

    body['client_id']
  end

  private

  def endpoint(route)
    "#{@api_base_url}#{route}"
  end
end
