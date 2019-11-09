require File.dirname(__FILE__) + '/../app/api_error_mapper'

describe 'ApiErrorMapper' do
  it 'maps invalid_username error to its counterparts' do
    mapper = ApiErrorMapper.new

    expect(mapper.map('invalid_username')).to eq('usuario invalido')
  end
end
