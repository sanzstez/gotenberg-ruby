require 'gotenberg/compiler'

module Gotenberg
  class Chromium
    module Tools
      # Adds a header to each page.
      # Note: it automatically sets the filename to "header.html", as required by Gotenberg.
      def header header
        compiler = Compiler.new(header)

        files << multipart_file(compiler.body, 'header.html', 'text/html')

        self
      end

      # Adds a footer to each page.
      # Note: it automatically sets the filename to "footer.html", as required by Gotenberg.
      def footer footer
        compiler = Compiler.new(footer)

        files << multipart_file(compiler.body, 'footer.html', 'text/html')

        self
      end

      # Converts an HTML document to PDF.
      # Note: it automatically sets the index filename to "index.html", as required by Gotenberg.
      # See https://gotenberg.dev/docs/modules/chromium#html.
      def html index
        compiler = Compiler.new(index)

        meta(extract_metadata_from_body(compiler.body))

        files << multipart_file(compiler.body, 'index.html', 'text/html')

        assets *compiler.assets

        @endpoint = '/forms/chromium/convert/html'

        self
      end

      # Converts one or more markdown files to PDF.
      # Note: it automatically sets the index filename to "index.html", as required by Gotenberg.
      # See https://gotenberg.dev/docs/modules/chromium#markdown.
      def markdown index, markdown
        files << multipart_file(index, 'index.html', 'text/html')
        files << multipart_file(*load_file_from_source(markdown), 'text/markdown')

        @endpoint = '/forms/chromium/convert/markdown'

        self
      end

      def assets *sources
        sources.each do |source|
          files << multipart_file(*load_file_from_source(source))
        end

        self
      end
    end
  end
end