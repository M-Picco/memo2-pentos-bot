class ApiErrorMapper
  ERRORS = {
    'invalid_username' => 'Usuario inválido',
    'invalid_address' => 'Dirección inválida',
    'invalid_phone' => 'Teléfono inválido',
    'server_error' => 'Error del servidor, espere y vuelva a intentarlo',
    "can't be blank" => 'Asegurese de ingresar todos los datos correspondientes ' \
                        '(Verifique username en la configuración de Telegram. ' \
                        'Verifique que el comando fue correctamente ingresado.)',
    'order not exist' => 'El pedido indicado no existe',
    'there are no orders' => 'Todavía no has realizado pedidos',
    'order_not_delivered' => 'El pedido solo puede calificarse una vez ENTREGADO',
    'invalid_rating' => "La calificación '%s' no es válida, ingresa un número entre 1 y 5"
  }.freeze

  GENERIC_MESSAGE = 'Error inesperado, espere y vuelva a intentarlo'.freeze

  def map(error, args = [])
    if ERRORS.key?(error)
      ERRORS[error] % args
    else
      GENERIC_MESSAGE
    end
  end
end
