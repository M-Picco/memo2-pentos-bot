class ApiErrorMapper
  ERRORS = {
    'invalid_username' => 'usuario invalido',
    'invalid_address' => 'direccion invalida'
  }.freeze

  def map(error)
    ERRORS[error]
  end
end
