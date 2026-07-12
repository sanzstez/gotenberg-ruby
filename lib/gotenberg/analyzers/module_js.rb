require 'gotenberg/analyzers/base'

module Gotenberg
  module Analyzers
    class ModuleJs < Base
      def tag
        '<script type="module" src="%s"></script>' % filename
      end

      def assets
        @assets ||= [[binary, filename]]
      end
    end
  end
end
