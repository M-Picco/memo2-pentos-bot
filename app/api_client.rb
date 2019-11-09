require_relative './api_error_mapper'

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

    return body['client_id'] if response.status == 200
    raise @error_mapper.map(body['error']) if response.status == 400

    raise @error_mapper.map('server_error')
  end

  def order(username)
    response = Faraday.post(endpoint("/client/#{username}/order"), {}.to_json, 'Content-Type' => 'application/json')
    body = JSON.parse(response.body)

    return body['order_id'] if response.status == 200

    raise @error_mapper.map('server_error')
  end

  private

  def endpoint(route)
    "#{@api_base_url}#{route}"
  end
end
