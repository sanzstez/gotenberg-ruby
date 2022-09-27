require 'gotenberg/analyzers/base'
require 'gotenberg/analyzers/resource'

module Gotenberg
  module Analyzers
    class Css < Base
      ASSETS_REGEX = /url\((?!['"]?(?:data|https?):)['"]?([^'"\)]*)['"]?\)/

      def call
        analyze_binary unless resource[:skip_analyze]

        self
      end

      def tag
        if resource[:inline]
          '<style type="text/css">%s</style>' % binary
        else
          '<link rel="stylesheet" href="%s" />' % filename
        end
      end

      def assets
        @assets ||= [[binary, filename]]
      end

      private

      def analyze_binary
        binary.gsub!(ASSETS_REGEX) do
          resource_src = File.join(resource[:base_path], $1)

          analyzer =
            Analyzers::Resource.new(resource.merge(src: resource_src)).call

          assets << analyzer.assets

          analyzer.tag
        end
      end
    end
  end
end