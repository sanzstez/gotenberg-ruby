module Gotenberg
  module Helpers
    module ViteHelpers
      def gotenberg_vite_image_tag source
        ensure_vite_ruby!

        path = gotenberg_vite_manifest.path_for(source)

        gotenberg_context_tag(
          tag: 'image',
          src: gotenberg_vite_source_location(path)
        )
      end

      def gotenberg_vite_stylesheet_tag source
        ensure_vite_ruby!

        path = gotenberg_vite_manifest.path_for(source, type: :stylesheet)

        gotenberg_context_tag(
          tag: 'css',
          src: gotenberg_vite_source_location(path),
          base_path: gotenberg_vite_stylesheet_base_path,
          skip_analyze: false
        )
      end

      def gotenberg_vite_javascript_tag source
        ensure_vite_ruby!

        entries = gotenberg_vite_manifest.resolve_entries(
          source,
          type: :javascript
        )

        tags = entries[:imports].map do |path|
          gotenberg_modulepreload_tag(path)
        end

        tags.concat(
          entries[:scripts].map do |path|
            gotenberg_modulejs_tag(path)
          end
        )

        safe_join(tags)
      end

      private

      def ensure_vite_ruby!
        return if Object.const_defined?(:ViteRuby)

        raise LoadError,
          'ViteRuby is required to use Gotenberg Vite helpers. Add vite_rails to your Gemfile.'
      end

      def gotenberg_modulejs_tag source
        gotenberg_context_tag(
          tag: 'modulejs',
          src: gotenberg_vite_source_location(source)
        )
      end

      def gotenberg_modulepreload_tag source
        gotenberg_context_tag(
          tag: 'modulepreload',
          src: gotenberg_vite_source_location(source)
        )
      end

      def gotenberg_vite_source_location source
        if Rails.env.development? || Rails.env.test?
          File.join(Rails.root, source)
        else
          File.join(Rails.public_path, source)
        end
      end

      def gotenberg_vite_stylesheet_base_path
        if Rails.env.development? || Rails.env.test?
          Rails.root.join(Gotenberg.configuration.vite_output_dir)
        else
          Rails.public_path
        end
      end

      def gotenberg_vite_manifest
        if Rails.env.development? || Rails.env.test?
          @gotenberg_vite_manifest ||= vite_internal_manifest.tap(&:refresh)
        else
          vite_manifest
        end
      end

      def vite_internal_manifest
        @vite_internal_manifest ||= ViteRuby.new(
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
