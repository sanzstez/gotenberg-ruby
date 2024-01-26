require 'gotenberg/pdf_engines/properties'
require 'gotenberg/pdf_engines/tools'
require 'gotenberg/headers'
require 'gotenberg/metadata'
require 'gotenberg/files'
require 'gotenberg/client'
require 'gotenberg/exiftools'
require 'gotenberg/exceptions'

module Gotenberg
  class PdfEngines
    include Properties, Files, Headers, Metadata, Tools

    attr_accessor :base_path, :client_headers
    attr_reader :endpoint, :response, :exception
    
    def self.call(base_path, headers: {}, &block)
      new(base_path: base_path, client_headers: headers, &block).call
    end

    def initialize args
      args.each do |key, value|
        public_send(('%s=' % key), value)
      end

      yield self if block_given?
    end

    def call
      transform
      modify_metadata if modify_metadata?

      self
    end

    def success?
      exception == nil
    end

    def to_binary
      response || raise(exception)
    end

    private

    def modify_metadata?
      return false if webhook_request?

      success? && metadata_available?
    end

    def transform
      @response = client.adapter.post(endpoint, properties.merge(files: files), headers).body
    rescue StandardError => e
      @exception = Gotenberg::TransformError.new(e)
    end

    def modify_metadata
      @response = Exiftools.modify(response, metadata)
    rescue StandardError => e
      @exception = Gotenberg::ModifyMetadataError.new(e)
    end

    def client
      Client.new(base_path, headers: client_headers)
    end
  end
end