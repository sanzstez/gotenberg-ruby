require 'base64'
require 'net/http'
require 'uri'
require 'gotenberg/exceptions'

module Gotenberg
  module Analyzers
    class Base
      URI_REGEXP = %r{^[-a-z]+://|^(?:cid|data):|^//}

      attr_accessor :resource

      def initialize resource
        @resource = resource
      end

      def call
        self
      end

      def assets
        [binary, filename]
      end

      private

      def binary
        @binary ||= remote? ? remote_source(src) : local_source(src)
      end

      def filename
        @filename ||= URI(File.basename(src)).path
      end

      def remote?
        src.match?(URI_REGEXP)
      end

      def src
        resource[:src]
      end

      def local_source path
        IO.binread(path)
      end

      def remote_source url
        Net::HTTP.get_response(URI(url)).body
      rescue StandardError => e
        raise RemoteSourceError.new('Unable to load remote source. %s' % e.message)
      end
    end
  end
end