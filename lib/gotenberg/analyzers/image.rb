require 'gotenberg/analyzers/base'
require 'gotenberg/utilities/inline_resource'

module Gotenberg
  module Analyzers
    class Image < Base
      def tag
        '<img src="%s" alt="%s" />' % [src_value, filename]
      end

      def assets
        @assets ||= [[binary, filename]]
      end

      private

      def src_value
        if resource[:inline]
          Gotenberg::Utilities::InlineResource.new(filename, binary).call
        else
          filename
        end
      end
    end
  end
end