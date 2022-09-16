require 'faraday'
require 'base64'
require 'gotenberg/analyzers/base'

module Gotenberg
  module Analyzers
    class Css < Base
      def tag
        if resource[:inline]
          '<style type="text/css">%s</style>' % binary
        else
          '<link rel="stylesheet" href="%s" />' % filename
        end
      end
    end
  end
end