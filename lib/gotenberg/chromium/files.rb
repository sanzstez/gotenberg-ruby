require 'faraday'
require 'faraday/multipart'
require 'gotenberg/compiler'

module Gotenberg
  class Chromium
    module Files
      # Adds a header to each page.
      # Note: it automatically sets the filename to "header.html", as required by Gotenberg.
      def header header
        compiler = Compiler.new(header)

        files << multipart_file(compiler.body, 'header.html', 'text/html')
      end

      # Adds a footer to each page.
      # Note: it automatically sets the filename to "footer.html", as required by Gotenberg.
      def footer footer
        compiler = Compiler.new(footer)

        files << multipart_file(compiler.body, 'footer.html', 'text/html')
      end

      # Converts an HTML document to PDF.
      # Note: it automatically sets the index filename to "index.html", as required by Gotenberg.
      # See https://gotenberg.dev/docs/modules/chromium#html.
      def html index
        compiler = Compiler.new(index)

        meta(extract_metadata_from_body(compiler.body))

        files << multipart_file(compiler.body, 'index.html', 'text/html')

        binary_assets(compiler.assets)

        @endpoint = '/forms/chromium/convert/html'

        self
      end

      # Converts one or more markdown files to PDF.
      # Note: it automatically sets the index filename to "index.html", as required by Gotenberg.
      # See https://gotenberg.dev/docs/modules/chromium#markdown.
      def markdown index, markdowns = []
        files << multipart_file(index, 'index.html', 'text/html')

        markdowns.each do |f|
          files << multipart_file(IO.binread(f), File.basename(f), 'text/markdown')
        end
        
        @endpoint = '/forms/chromium/convert/markdown'

        self
      end

      # Sets the additional files, like images, fonts, stylesheets, and so on.
      def binary_assets sources
        sources.each do |(io, filename)|
          files << multipart_file(io, filename)
        end

        self
      end

      def assets sources
        sources.each do |f|
          files << multipart_file(IO.binread(f), File.basename(f))
        end

        self
      end

      def files
        @files ||= []
      end

      private

      def multipart_file body, filename, content_type = 'application/octet-stream'
        Faraday::Multipart::FilePart.new(StringIO.new(body), content_type, filename)
      end
    end
  end
end