require 'base64'

module Gotenberg
  module Utilities
    class InlineResource
      MIME_TYPES = {
        'bmp' => 'image/bmp',
        'gif' => 'image/gif',
        'png' => 'image/png',
        'jpe' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'jpg' => 'image/jpeg',
        'jfif' => 'image/pipeg',
        'svg' => 'image/svg+xml',
        'tif' => 'image/tiff',
        'tiff' => 'image/tiff',
        'ico' => 'image/x-icon',
        'eot' => 'application/vnd.ms-fontobject',
        'otf' => 'application/font-sfnt',
        'ttf' => 'application/font-sfnt',
        'woff' => 'application/font-woff',
        'woff2' => 'application/font-woff2',
      }.freeze

      attr_reader :filename, :binary

      def initialize filename, binary
        @filename = filename
        @binary = binary
      end

      def call
        'data:%s;base64,%s' % [mimetype, Base64.strict_encode64(binary)]
      end

      private

      def extension
        @extension ||= File.extname(filename).downcase[1..-1]
      end

      def mimetype
        @mimetype ||= MIME_TYPES[extension] || 'application/octet-stream'
      end
    end
  end
end