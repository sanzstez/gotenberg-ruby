require 'gotenberg/chromium/properties'
require 'gotenberg/chromium/files'
require 'gotenberg/chromium/headers'
require 'gotenberg/chromium/metadata'
require 'gotenberg/client'
require 'gotenberg/exiftools'
require 'gotenberg/extractors'

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
      transform

      if success? && metadata_available? 
        modify_metadata
      end

      self
    end

    def success?
      @exception == nil
    end

    def to_binary
      response
    end

    private

    def transform
      @response = client.adapter.post(endpoint, properties.merge(files: files), headers).body
    rescue StandardError => e
      @exception = e
    end

    def modify_metadata
      @response = Exiftools.modify(response, metadata)
    rescue StandardError => e
      @exception = e
    end

    def client
      @client ||= Client.new(base_path)
    end
  end
end