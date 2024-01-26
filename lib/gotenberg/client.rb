require 'faraday'
require 'faraday/multipart'

module Gotenberg
  class Client
    attr_reader :base_path, :headers

    def initialize base_path, headers: {}
      @base_path = base_path
      @headers = headers
    end

    def adapter
      @adapter ||= Faraday.new(base_path, headers: default_headers) do |c|
        c.request :multipart
        c.request :url_encoded
        c.adapter :net_http
        c.response :raise_error
      end
    end

    def default_headers
      {'Content-Type' => 'multipart/form-data'}.merge(headers)
    end
  end
end