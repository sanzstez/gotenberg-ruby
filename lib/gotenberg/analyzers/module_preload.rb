require 'gotenberg/analyzers/base'

module Gotenberg
  module Analyzers
    class ModulePreload < Base
      def tag
        '<link rel="modulepreload" href="%s" />' % filename
      end

      def assets
        @assets ||= [[binary, filename]]
      end
    end
  end
end
