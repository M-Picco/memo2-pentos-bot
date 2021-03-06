require_relative './api_error_mapper'
require_relative './api_status_mapper'

class ApiClient
  def initialize(api_base_url)
    @api_base_url = api_base_url
    @error_mapper = ApiErrorMapper.new
    @status_mapper = ApiStatusMapper.new
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

  def order(username, menu)
    params = {
      order: menu
    }

    response = Faraday.post(endpoint("/client/#{username}/order"), params.to_json, 'Content-Type' => 'application/json')
    body = JSON.parse(response.body)

    return body['order_id'] if response.status == 200
    raise @error_mapper.map(body['error']) if response.status == 400

    raise @error_mapper.map('server_error')
  end

  def order_status(username, order_id)
    response = Faraday.get endpoint("/client/#{username}/order/#{order_id}")
    body = JSON.parse(response.body)
    return @status_mapper.map(body['order_status']) if response.status == 200
    raise @error_mapper.map(body['error']) if response.status == 400

    raise @error_mapper.map('server_error')
  end

  def order_rate(username, order_id, rating)
    params = {
      rating: rating
    }

    response = Faraday.post(endpoint("/client/#{username}/order/#{order_id}/rate"),
                            params.to_json, 'Content-Type' => 'application/json')

    body = JSON.parse(response.body)

    return body['rating'] if response.status == 200
    raise @error_mapper.map(body['error'], [rating]) if response.status == 400
  end

  private

  def endpoint(route)
    "#{@api_base_url}#{route}"
  end
end
