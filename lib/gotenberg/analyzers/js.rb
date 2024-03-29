require 'base64'
require 'gotenberg/analyzers/base'

module Gotenberg
  module Analyzers
    class Js < Base
      def tag
        if resource[:inline]
          '<script type="text/javascript">%s</script>' % binary
        else
          '<script src="%s"></script>' % filename
        end
      end

      def assets
        @assets ||= [[binary, filename]]
      end
    end
  end
end