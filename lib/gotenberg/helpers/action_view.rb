module Gotenberg
  module Helpers
    module ActionView
      def gotenberg_image_tag source, options = {}
        options[:tag] = 'image'
        options[:src] = gotenberg_source_location(source, options)

        gotenberg_context_tag(options)
      end

      def gotenberg_javascript_tag source, options = {}
        options[:tag] = 'js'
        options[:src] = gotenberg_source_location(source, options)

        gotenberg_context_tag(options)
      end

      def gotenberg_stylesheet_tag source, options = {}
        options[:tag] = 'css'
        options[:src] = gotenberg_source_location(source, options)

        options[:base_path] =
          case gotenberg_source_type(options)
          when :absolute
            Rails.root
          when :proxy
            compute_asset_host(source, protocol: :request)
          when :static
            Rails.public_path
          end

        options[:skip_analyze] ||= false

        gotenberg_context_tag(options)
      end

      private

      def gotenberg_source_type options = {}
        return :absolute if options[:absolute_path]

        if Rails.application.config.asset_host || Rails.application.config.action_controller.asset_host
          raise <<-EOF.squish
              You can not use Gotenberg tag helpers for assets with "asset_host" option. Use standard rails assets tag helpers.
            EOF
        end

        Rails.env.development? ? :proxy : :static
      end

      def gotenberg_source_location source, options = {}
        case gotenberg_source_type(options)
        when :absolute
          File.join(Rails.root, source)
        when :proxy
          gotenberg_asset_location(source, :url)
        when :static
          File.join(Rails.public_path, gotenberg_asset_location(source, :path))
        end
      end

      def gotenberg_context_tag attributes
        ('<!-- GOTENBERG-CONTEXT-TAG %s -->' % attributes.to_json).html_safe 
      end

      def gotenberg_asset_location source, type
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