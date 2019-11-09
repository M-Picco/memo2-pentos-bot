class ApiErrorMapper
  ERRORS = {
    'invalid_username' => 'usuario invalido',
    'invalid_address' => 'direccion invalida',
    'invalid_phone' => 'telefono invalido',
    'server_error' => 'error del servidor, espere y vuelva a intentarlo'
  }.freeze

  def map(error)
    ERRORS[error]
  end
end
