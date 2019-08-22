# frozen_string_literal: true

require 'securerandom'
require 'base64'
require 'openssl'
require 'json'

# The AliyunSDK module
module AliyunSDK
  VERSION = '0.0.3'

  def self.replace_repeat_list(target, key, repeat)
    repeat.each_with_index do |item, index|
      if item&.instance_of?(Hash)
        item.each_key do |k|
          target["#{key}.#{index.next}.#{k}"] = item[k].to_s
        end
      else
        target["#{key}.#{index.next}"] = item.to_s
      end
    end
    target
  end

  def self.flat_params(params)
    target = {}
    params.each do |key, value|
      if value.instance_of?(Array)
        replace_repeat_list(target, key, value)
      else
        target[key.to_s] = value
      end
    end
    target
  end

  def self.canonicalize(normalized)
    normalized.map { |element| "#{element.first}=#{element.last}" }.join('&')
  end

  def self.normalize(params)
    flat_params(params)
      .sort
      .to_h
      .map { |key, value| [encode(key), encode(value)] }
  end

  def self.encode(string)
    encoded = CGI.escape string
    encoded.gsub(/[\+]/, '%20')
  end

  # The RPCClient class
  class RPCClient
    attr_accessor :__access_key_id, :__access_key_secret, :__region_id, :__protocol,
                  :__endpoint, :__version, :credential, :codes

    def initialize(config)
      self.__access_key_id = config[:accessKeyId]
      self.__access_key_secret = config[:accessKeySecret]
      self.__version = config[:apiVersion]
      self.credential = config[:credential]
      self.__endpoint = config[:endpoint]
      self.__region_id = config[:regionId]
      self.__protocol = config[:protocol]
      self.codes = Set.new [200, '200', 'OK', 'Success']
      codes.merge config[:codes] if config[:codes]
    end

    def __get_timestamp
      Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
    end

    def __get_nonce
      SecureRandom.hex(16)
    end

    def __get_access_key_id
      __access_key_id
    end

    def __get_access_key_secret
      __access_key_secret
    end

    def __get_endpoint(product, region_id)
      return __endpoint if __endpoint

      "#{product}.#{region_id}.aliyuncs.com"
    end

    def __is5xx(response)
      code = response.code.to_i
      code >= 500 && code < 600
    end

    def __has_error(body)
      code = body['Code']
      code && !codes.include?(code)
    end

    def __json(response)
      JSON.parse(response.body)
    end

    def __query(query)
      target = {}
      query.each do |key, value|
        if value.instance_of?(Array)
          replace_repeat_list(target, key, value)
        else
          target[key] = value.to_s
        end
      end
      target
    end

    def __default_number(input, default)
      input || default
    end

    def __default(input, default)
      input || default
    end

    def __get_signature(request, access_key_secret)
      method = (request[:method] || 'GET').upcase
      normalized = AliyunSDK.normalize(request['query'])
      canonicalized = AliyunSDK.canonicalize(normalized)
      string2sign = "#{method}&#{AliyunSDK.encode('/')}&#{AliyunSDK.encode(canonicalized)}"
      key = access_key_secret + '&'
      Base64.encode64(OpenSSL::HMAC.digest('sha1', key, string2sign)).strip
    end
  end
end
