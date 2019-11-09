class ApiErrorMapper
  ERRORS = {
    'invalid_username' => 'usuario invalido',
    'invalid_address' => 'direccion invalida',
    'invalid_phone' => 'telefono invalido'
  }.freeze

  def map(error)
    ERRORS[error]
  end
end
