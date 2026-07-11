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

      def gotenberg_modulejs_tag source, options = {}
        options[:tag] = 'modulejs'
        options[:src] = gotenberg_source_location(source, options)

        gotenberg_context_tag(options)
      end

      def gotenberg_modulepreload_tag source, options = {}
        options[:tag] = 'modulepreload'
        options[:src] = gotenberg_source_location(source, options)

        gotenberg_context_tag(options)
      end

      def gotenberg_stylesheet_tag source, options = {}
        options[:tag] = 'css'
        options[:src] = gotenberg_source_location(source, options)

        options[:base_path] ||=
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

      def gotenberg_vite_stylesheet_tag source, options = {}
        gotenberg_stylesheet_tag(
          gotenberg_vite_manifest.path_for(source, type: :stylesheet),
          gotenberg_vite_options(options)
        )
      end

      def gotenberg_vite_javascript_tag source, options = {}
        entries = gotenberg_vite_manifest.resolve_entries(source, type: :javascript)
        vite_options = gotenberg_vite_options(options)

        tags = []

        entries[:imports].each do |path|
          tags << gotenberg_modulepreload_tag(path, vite_options)
        end

        entries[:scripts].each do |path|
          tags << gotenberg_modulejs_tag(path, vite_options)
        end

        safe_join(tags)
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
        vite = Module.const_defined?(:ViteRuby)

        return source if vite

        case type
        when :path
          public_send((webpacker ? :asset_pack_path : :asset_path), source)
        when :url
          public_send((webpacker ? :asset_pack_url : :asset_url), source)
        end
      end

      def gotenberg_vite_manifest
        if Rails.env.development?
          manifest = gotenberg_vite_pdf_manifest
          manifest.refresh
          manifest
        else
          vite_manifest
        end
      end

      def gotenberg_vite_options options
        if Rails.env.development?
          options.merge(
            absolute_path: true,
            base_path: Rails.root.join(Gotenberg.configuration.vite_output_dir)
          )
        else
          options
        end
      end

      def gotenberg_vite_pdf_manifest
        @gotenberg_vite_pdf_manifest ||= ViteRuby.new(
          root: Rails.root.to_s,
          mode: 'production',
          public_dir: '.',
          public_output_dir: Gotenberg.configuration.vite_output_dir,
          source_code_dir: Gotenberg.configuration.vite_source_code_dir,
          auto_build: false
        ).manifest
      end
    end
  end
end
