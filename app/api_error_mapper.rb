class ApiErrorMapper
  ERRORS = {
    'invalid_username' => 'Usuario invalido',
    'invalid_address' => 'Direccion invalida',
    'invalid_phone' => 'Telefono invalido',
    'server_error' => 'Error del servidor, espere y vuelva a intentarlo',
    "can't be blank" => 'Asegurese de ingresar todos los datos correspondientes'
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
