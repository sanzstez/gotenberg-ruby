require 'json'

module Gotenberg
  class Chromium
    module Metadata
      # set meta headers for PDF file with exiftools (title, creator, etc...)
      def meta elements
        metadata.merge!(elements)

        self
      end

      def metadata_available?
        !metadata.empty?
      end

      private

      def metadata
        @metadata ||= {}
      end
    end
  end
end