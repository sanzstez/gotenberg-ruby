require 'faraday'
require 'base64'
require 'gotenberg/exceptions'

module Gotenberg
  module Analyzers
    class Base
      URI_REGEXP = %r{^[-a-z]+://|^(?:cid|data):|^//}

      attr_accessor :resource

      def initialize resource
        @resource = resource
      end

      def assets
        [binary, filename]
      end

      private

      def binary
        @binary ||= remote? ? remote_source : local_source
      end

      def remote_source
        Faraday.get(src).body
      rescue StandardError => e
        raise RemoteSourceError.new('Unable to load remote source. %s' % e.message)
      end

      def local_source
        IO.binread(src)
      end

      def extension
        @extension ||= File.extname(filename).strip.downcase[1..-1]
      end

      def filename
        @filename ||= File.basename(src)
      end

      def remote?
        src.match?(URI_REGEXP)
      end

      def src
        resource[:src]
      end
    end
  end
end