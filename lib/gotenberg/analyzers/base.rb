require 'faraday'
require 'base64'

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

      def filename
        File.basename(path)
      end

      def remote_source
        Faraday.get(path).body
      rescue StandardError => e
        raise 'Unable to load remote source. %s' % e.message
      end

      def local_source
        IO.binread(path)
      end

      def remote?
        path.match?(URI_REGEXP)
      end

      def path
        resource[:src]
      end
    end
  end
end