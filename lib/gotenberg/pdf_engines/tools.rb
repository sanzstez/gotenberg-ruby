require 'gotenberg/utilities/index'

module Gotenberg
  class PdfEngines
    module Tools

      # Merges PDFs into a unique PDF.
      # Note: the merging order is determined by the order of the arguments.
      # See https://gotenberg.dev/docs/modules/pdf-engines#merge.
      def merge *sources
        sources.each.with_index(1) do |source, index|
          io, filename = load_file_from_source(source)
          
          files << multipart_file(io, merge_prefix(index) + filename)
        end

        @endpoint = '/forms/pdfengines/merge'

        self
      end

      # Converts PDF(s) to a specific PDF format.
      # Gotenberg will return the PDF or a ZIP archive with the PDFs.
      # https://gotenberg.dev/docs/modules/pdf-engines#convert.
      # https://gotenberg.dev/docs/modules/pdf-engines#engines.
      def convert *sources, format: 'PDF/A-1a'
        sources.each do |source|
          files << multipart_file(*load_file_from_source(source))
        end

        properties['pdfFormat'] = format

        @endpoint = '/forms/pdfengines/convert'
        @pdf_engines_convert = true

        self
      end

      private

      def zip_mode?
        @pdf_engines_convert && files.size > 1
      end

      def merge_prefix number
        Gotenberg::Utilities::Index::to_alpha(number) + '_'
      end
    end
  end
end