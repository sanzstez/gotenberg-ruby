require 'gotenberg/chromium/properties'
require 'gotenberg/chromium/files'
require 'gotenberg/chromium/headers'
require 'gotenberg/chromium/metadata'
require 'gotenberg/client'
require 'gotenberg/exiftools'
require 'gotenberg/extractors'
require 'gotenberg/exceptions'
require 'gotenberg/backtrace'

module Gotenberg
  class Chromium
    include Properties, Files, Headers, Metadata, Extractors

    attr_accessor :base_path
    attr_reader :endpoint, :response, :exception
    
    def self.call(base_path, &block)
      new(base_path: base_path, &block).call
    end

    def initialize args
      args.each do |key, value|
        public_send(('%s=' % key), value)
      end

      yield self if block_given?
    end

    def call
      backtrace if html_debug?
      transform

      if success? && metadata_available?
        modify_metadata
      end

      self
    end

    def success?
      exception == nil
    end

    def to_binary
      response || raise(exception)
    end

    def html_debug?
      Gotenberg.configuration.html_debug == true
    end

    private

    def backtrace
      Backtrace.new(files).call
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
      Client.new(base_path)
    end
  end
end