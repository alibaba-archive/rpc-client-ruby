require 'rspec'

require 'rpc_client'

describe 'RPC client' do

  it 'flat_params should ok' do
    h = {}
    r = AliyunSDK.flat_params(h)
    expect(r).to eql({})

    h = {'key': 'value'}
    r = AliyunSDK.flat_params(h)
    expect(r).to eql({
      "key" => "value"
    })

  end

end