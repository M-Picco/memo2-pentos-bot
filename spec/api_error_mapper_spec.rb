require File.dirname(__FILE__) + '/../app/api_error_mapper'

describe 'ApiErrorMapper' do
  it 'maps invalid_username error to its counterparts' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('invalid_username')).to eq('Usuario inválido')
  end

  it 'maps invalid_address error to its counterparts' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('invalid_address')).to eq('Dirección inválida')
  end

  it 'maps invalid_phone error to its counterparts' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('invalid_phone')).to eq('Teléfono inválido')
  end

  it 'maps server_error error to its counterparts' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('server_error')).to eq('Error del servidor, espere y vuelva a intentarlo')
  end

  it 'maps can\'t be blank to its generic counterpart' do
    mapper = ApiErrorMapper.new

    expect(mapper.map("can't be blank")).to eq('Asegurese de ingresar todos los datos correspondientes ' \
                                               '(Verifique username en la configuración de Telegram. ' \
                                               'Verifique que el comando fue correctamente ingresado.)')
  end

  it 'maps order not exist to its counterpart' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('order not exist')).to eq('El pedido indicado no existe')
  end

  it 'returns a generic message when it does not know ow to map an error' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('not_known_error')).to eq('Error inesperado, espere y vuelva a intentarlo')
  end
end
