class ApiErrorMapper
  ERRORS = {
    'invalid_username' => 'usuario invalido',
    'invalid_address' => 'direccion invalida',
    'invalid_phone' => 'telefono invalido',
    'server_error' => 'error del servidor, espere y vuelva a intentarlo',
    "can't be blank" => 'asegurese de ingresar todos los datos correspondientes'
  }.freeze

  GENERIC_MESSAGE = 'error inesperado, espere y vuelva a intentarlo'.freeze

  def map(error)
    if ERRORS.key?(error)
      ERRORS[error]
    else
      GENERIC_MESSAGE
    end
  end
end
