require 'faraday'
require 'base64'
require 'gotenberg/analyzers/base'

module Gotenberg
  module Analyzers
    class Image < Base
      MIME_TYPES = {
        'bmp' => 'image/bmp',
        'gif' => 'image/gif',
        'jpe' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'jpg' => 'image/jpeg',
        'jfif' => 'image/pipeg',
        'svg' => 'image/svg+xml',
        'tif' => 'image/tiff',
        'tiff' => 'image/tiff',
        'ico' => 'image/x-icon'
      }.freeze

      def tag
        '<img src="%s" alt="%s" />' % [src_value, filename]
      end

      private

      def src_value
        if resource[:inline]
          'data:%s;base64,%s' % [mimetype, Base64.strict_encode64(binary)]
        else
          filename
        end
      end

      def mimetype
        MIME_TYPES[extension] || 'application/octet-stream'
      end
    end
  end
end