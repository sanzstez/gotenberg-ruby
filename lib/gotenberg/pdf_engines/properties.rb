module Gotenberg
  class PdfEngines
    module Properties

      # Sets the PDF format of the resulting PDF.
      # See https://gotenberg.dev/docs/modules/pdf-engines#engines.
      def pdf_format format
        properties['pdfFormat'] = format

        self
      end

      private

      def properties
        @properties ||= {}
      end
    end
  end
end