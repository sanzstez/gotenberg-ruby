require 'faraday'
require 'faraday/multipart'
require 'gotenberg/utilities/index'

module Gotenberg
  class PdfEngines
    module Files

      # Merges PDFs into a unique PDF.
      # Note: the merging order is determined by the order of the arguments.
      # See https://gotenberg.dev/docs/modules/pdf-engines#merge.
      def merge *sources
        sources.each.with_index(1) do |source, index|
          files << multipart_file(IO.binread(source), merge_prefix(index) + File.basename(source))
        end

        @endpoint = '/forms/pdfengines/merge'

        self
      end

      # Converts PDF(s) to a specific PDF format.
      # Gotenberg will return the PDF or a ZIP archive with the PDFs.
      # https://gotenberg.dev/docs/modules/pdf-engines#convert.
      # https://gotenberg.dev/docs/modules/pdf-engines#engines.
      def convert format, *sources
        properties['pdfFormat'] = format

        sources.each.with_index(1) do |source, index|
          files << multipart_file(IO.binread(source), File.basename(source))
        end

        @endpoint = '/forms/pdfengines/convert'
        @pdf_engines_convert = true

        self
      end

      private

      def files
        @files ||= []
      end

      def zip_mode?
        @pdf_engines_convert && files.size > 1
      end

      def merge_prefix number
        Gotenberg::Utilities::Index::to_alpha(number) + '_'
      end

      def multipart_file body, filename, content_type = 'application/octet-stream'
        Faraday::Multipart::FilePart.new(StringIO.new(body), content_type, filename)
      end
    end
  end
end