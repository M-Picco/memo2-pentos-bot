class ApiStatusMapper
  STATUS = {
    'recibido' => 'ha sido RECIBIDO',
    'en_preparacion' => 'esta EN PREPARACION',
    'en_entrega' => 'esta EN ENTREGA',
    'entregado' => 'esta ENTREGADO',
    'cancelado' => 'esta CANCELADO',
    'en_espera' => 'esta EN ESPERA'
  }.freeze

  GENERIC_MESSAGE = 'Estado desconocido'.freeze

  def map(order_status)
    if STATUS.key?(order_status)
      STATUS[order_status]
    else
      GENERIC_MESSAGE
    end
  end
end
