require File.dirname(__FILE__) + '/../app/api_error_mapper'

describe 'ApiErrorMapper' do
  it 'maps invalid_username error to its counterparts' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('invalid_username')).to eq('usuario invalido')
  end

  it 'maps invalid_address error to its counterparts' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('invalid_address')).to eq('direccion invalida')
  end

  it 'maps invalid_phone error to its counterparts' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('invalid_phone')).to eq('telefono invalido')
  end

  it 'maps server_error error to its counterparts' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('server_error')).to eq('error del servidor, espere y vuelva a intentarlo')
  end

  it 'returns a generic message when it does not know ow to map an error' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('not_known_error')).to eq('error inesperado, espere y vuelva a intentarlo')
  end
end
