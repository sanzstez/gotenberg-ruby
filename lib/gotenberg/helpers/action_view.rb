module Gotenberg
  module Helpers
    module ActionView
      def gotenberg_image_tag source, options = {}
        gootenberg_source_tag(source, options.merge(tag: 'image'))
      end

      def gotenberg_javascript_tag source, options = {}
        gootenberg_source_tag(source, options.merge(tag: 'js'))
      end

      def gotenberg_stylesheet_tag source, options = {}
        gootenberg_source_tag(source, options.merge(tag: 'css'))
      end

      private

      def gootenberg_source_tag source, options = {}
        src = if options[:absolute_path]
          File.join(Rails.root, source)
        elsif Rails.env.development?
          gootenberg_asset_location(source, :url)
        else
          File.join(Rails.public_path, gootenberg_asset_location(source, :path))
        end

        gootenberg_context_tag(src: src, **options)
      end

      def gootenberg_context_tag attributes
        ('<!-- GOTENBERG-CONTEXT-TAG %s -->' % attributes.to_json).html_safe 
      end

      def gootenberg_asset_location source, type
        webpacker = Module.const_defined?(:Webpacker)

        case type
        when :path
          public_send((webpacker ? :asset_pack_path : :asset_path), source)
        when :url
          public_send((webpacker ? :asset_pack_url : :asset_url), source)
        end
      end
    end
  end
end