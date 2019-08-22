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

    h = {'key': ["1", "2"]}
    r = AliyunSDK.flat_params(h)
    expect(r).to eql({
      "key.1" => "1",
      "key.2" => "2",
    })

  end

  it '__get_timestamp should ok' do
    client = AliyunSDK::RPCClient.new({})
    ts = client.__get_timestamp()
    expect(ts).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
  end

  it '__get_nonce should ok' do
    client = AliyunSDK::RPCClient.new({})
    ts = client.__get_nonce()
    expect(ts).to match(/[\da-z]{32}/)
  end

  it '__get_access_key_id should ok' do
    client = AliyunSDK::RPCClient.new(
      :accessKeyId => 'accessKeyId'
    )
    akid = client.__get_access_key_id()
    expect(akid).to eq('accessKeyId')
  end

  it '__get_access_key_secret should ok' do
    client = AliyunSDK::RPCClient.new(
      :accessKeySecret => 'accessKeySecret'
    )
    aksecret = client.__get_access_key_secret()
    expect(aksecret).to eq('accessKeySecret')
  end

  it '__get_endpoint should ok' do
    client = AliyunSDK::RPCClient.new(
      :endpoint => 'endpoint'
    )

    endpoint = client.__get_endpoint 'product', 'region_id'
    expect(endpoint).to eq('endpoint')

    client = AliyunSDK::RPCClient.new({})

    endpoint = client.__get_endpoint 'product', 'region_id'
    expect(endpoint).to eq('product.region_id.aliyuncs.com')
  end

end