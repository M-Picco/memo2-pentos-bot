class ApiErrorMapper
  ERRORS = {
    'invalid_username' => 'Usuario inválido',
    'invalid_address' => 'Dirección inválida',
    'invalid_phone' => 'Teléfono inválido',
    'server_error' => 'Error del servidor, espere y vuelva a intentarlo',
    "can't be blank" => 'Asegurese de ingresar todos los datos correspondientes ' \
                        '(Verifique username en la configuración de Telegram. ' \
                        'Verifique que el comando fue correctamente ingresado.)',
    'order not exist' => 'El pedido indicado no existe'
  }.freeze

  GENERIC_MESSAGE = 'Error inesperado, espere y vuelva a intentarlo'.freeze

  def map(error)
    if ERRORS.key?(error)
      ERRORS[error]
    else
      GENERIC_MESSAGE
    end
  end
end
