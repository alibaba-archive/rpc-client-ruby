# frozen_string_literal: true

require 'net/http'

require 'rspec'

require 'rpc_client'

describe 'RPC client' do
  it 'flat_params should ok' do
    h = {}
    r = AliyunSDK.flat_params(h)
    expect(r).to eql({})

    h = { 'key': 'value' }
    r = AliyunSDK.flat_params(h)
    expect(r).to eql(
      'key' => 'value'
    )

    h = { 'key': %w[1 2] }
    r = AliyunSDK.flat_params(h)
    expect(r).to eql(
      'key.1' => '1',
      'key.2' => '2'
    )

    h = { 'key': [{ 'k2': 'value' }] }
    r = AliyunSDK.flat_params(h)
    expect(r).to eql(
      'key.1.k2' => 'value'
    )
  end

  it 'normalize should ok' do
    h = {}
    r = AliyunSDK.normalize(h)
    expect(r).to eql([])

    h = { 'key': 'value' }
    r = AliyunSDK.normalize(h)
    expect(r).to eql([
                       %w[key value]
                     ])

    h = { 'key': %w[1 2] }
    r = AliyunSDK.normalize(h)
    expect(r).to eql([['key.1', '1'], ['key.2', '2']])

    h = { 'key': [{ 'k2': 'value' }] }
    r = AliyunSDK.normalize(h)
    expect(r).to eql(
      [['key.1.k2', 'value']]
    )
  end

  it '__get_timestamp should ok' do
    client = AliyunSDK::RPCClient.new({})
    ts = client.__get_timestamp
    expect(ts).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
  end

  it '__get_nonce should ok' do
    client = AliyunSDK::RPCClient.new({})
    ts = client.__get_nonce
    expect(ts).to match(/[\da-z]{32}/)
  end

  it '__get_access_key_id should ok' do
    client = AliyunSDK::RPCClient.new(
      accessKeyId: 'accessKeyId'
    )
    akid = client.__get_access_key_id
    expect(akid).to eq('accessKeyId')
  end

  it '__get_access_key_secret should ok' do
    client = AliyunSDK::RPCClient.new(
      accessKeySecret: 'accessKeySecret'
    )
    aksecret = client.__get_access_key_secret
    expect(aksecret).to eq('accessKeySecret')
  end

  it '__get_endpoint should ok' do
    client = AliyunSDK::RPCClient.new(
      endpoint: 'endpoint'
    )

    endpoint = client.__get_endpoint 'product', 'region_id'
    expect(endpoint).to eq('endpoint')

    client = AliyunSDK::RPCClient.new({})

    endpoint = client.__get_endpoint 'product', 'region_id'
    expect(endpoint).to eq('product.region_id.aliyuncs.com')
  end

  it '__query should ok' do
    client = AliyunSDK::RPCClient.new({})
    r = client.__query({})
    expect(r).to eql({})

    r = client.__query(
      'key': 'value'
    )
    expect(r).to eql(
      key: 'value'
    )

    r = client.__query(
      'key': 'value',
      'array': %w[1 2]
    )
    expect(r).to eql(
      key: 'value',
      'array.1' => '1',
      'array.2' => '2'
    )
  end

  it '__default_number should ok' do
    client = AliyunSDK::RPCClient.new({})

    r = client.__default_number nil, 10
    expect(r).to eq(10)
  end

  it '__default should ok' do
    client = AliyunSDK::RPCClient.new({})

    r = client.__default nil, 10
    expect(r).to eq(10)
  end

  it '__get_signature should ok' do
    client = AliyunSDK::RPCClient.new({})
    r = client.__get_signature({
                                 'method' => 'GET',
                                 'query' => {}
                               }, 'access_key_secret')
    expect(r).to eq('uVPjs2GBLHS4BwWRTYNdafss1ho=')
  end

  it '__json should ok' do
    client = AliyunSDK::RPCClient.new({})
    stub_request(:any, 'www.example.com')
      .to_return(
        body: '{}',
        status: 200,
        headers: { 'Content-Length' => 3 }
      )

    response = Net::HTTP.get_response('www.example.com', '/')
    r = client.__json(response)
    expect(r).to eql({})
  end

  it '__is5xx should ok' do
    client = AliyunSDK::RPCClient.new({})
    stub_request(:any, 'www.example.com')
      .to_return(
        body: '{}',
        status: 200,
        headers: { 'Content-Length' => 3 }
      )

    response = Net::HTTP.get_response('www.example.com', '/')
    r = client.__is5xx(response)
    expect(r).to eq(false)

    stub_request(:any, 'www.example.com')
      .to_return(
        body: '{}',
        status: 500,
        headers: { 'Content-Length' => 3 }
      )

    response = Net::HTTP.get_response('www.example.com', '/')
    r = client.__is5xx(response)
    expect(r).to eq(true)
  end

  it '__has_error should ok' do
    client = AliyunSDK::RPCClient.new({})
    r = client.__has_error(
      'Code' => '200'
    )
    expect(r).to eq(false)

    r = client.__has_error(
      'Code' => '500'
    )
    expect(r).to eq(true)
  end
end
