require_relative './api_error_mapper'
require_relative './api_status_mapper'

class ApiClient
  def initialize(api_base_url, api_key = (ENV['API_KEY'] || 'zaraza'))
    @api_base_url = api_base_url
    @api_key = api_key
    @error_mapper = ApiErrorMapper.new
    @status_mapper = ApiStatusMapper.new
  end

  def register(username, address, phone)
    params = {
      username: username,
      address: address,
      phone: phone
    }

    response = Faraday.post(endpoint('/client'), params.to_json, header)
    body = JSON.parse(response.body)

    return body['client_id'] if response.status == 200
    raise @error_mapper.map(body['error']) if response.status == 400

    raise @error_mapper.map('server_error')
  end

  def order(username, menu)
    params = {
      order: menu
    }

    response = Faraday.post(endpoint("/client/#{username}/order"), params.to_json, header)
    body = JSON.parse(response.body)

    return body['order_id'] if response.status == 200
    raise @error_mapper.map(body['error']) if response.status == 400

    raise @error_mapper.map('server_error')
  end

  def order_status(username, order_id)
    response = Faraday.get(endpoint("/client/#{username}/order/#{order_id}"), {}, header)

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
                            params.to_json, header)

    body = JSON.parse(response.body)

    return body['rating'] if response.status == 200
    raise @error_mapper.map(body['error'], [rating]) if response.status == 400
  end

  def order_cancel(_username, order_id)
    response = Faraday.put(endpoint("/order/#{order_id}/cancel"), {}.to_json, header)

    return 'Pedido cancelado con éxito' if response.status == 200

    body = JSON.parse(response.body)
    raise @error_mapper.map(body['error']) if response.status == 400

    raise @error_mapper.map('server_error')
  end

  def historical_orders(username)
    response = Faraday.get(endpoint("/client/#{username}/historical"), {}, header)
    body = JSON.parse(response.body)

    return ['No tiene pedidos completos'] if body.empty? && response.status == 200

    return format_orders(body) if response.status == 200

    raise @error_mapper.map('server_error')
  end

  def estimated_time(username, order_id)
    response = Faraday.get(endpoint("/client/#{username}/order/#{order_id}"), {}, header)
    body = JSON.parse(response.body)

    return "#{body['estimated_delivery_time']} minutos" if response.status == 200

    raise @error_mapper.map(body['error']) if response.status == 400

    raise @error_mapper.map('server_error')
  end

  private

  def endpoint(route)
    "#{@api_base_url}#{route}"
  end

  def header
    { 'Content-Type' => 'application/json', 'api-key' => @api_key }
  end

  def format_orders(orders)
    orders.map do |order|
      "Nro : #{order['id']}\n" \
        "Dia : #{order['date']}\n" \
        "Menú : #{order['menu']}\n" \
        "Repartidor : #{order['assigned_to']}\n"
    end
  end
end
