require 'gotenberg/analyzers/base'
require 'gotenberg/utilities/inline_resource'

module Gotenberg
  module Analyzers
    class Resource < Base
      def tag
        'url(%s)' % src_value
      end

      def assets
        [binary, filename]
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