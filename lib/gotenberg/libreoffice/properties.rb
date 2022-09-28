module Gotenberg
  class Libreoffice
    module Properties

      # Sets the paper orientation to landscape.
      def landscape
        properties['landscape'] = true

        self
      end

      # Set the page ranges to print, e.g., "1-5, 8, 11-13". Empty means all pages.
      # Note: the page ranges are applied to all files independently.
      def native_page_ranges ranges
        properties['nativePageRanges'] = ranges

        self
      end

      # Tells Gotenberg to use unoconv for converting the resulting PDF to a PDF format.
      def native_pdf_format format
        properties['nativePdfFormat'] = format

        self
      end

      # Sets the PDF format of the resulting PDF.
      # See https://gotenberg.dev/docs/modules/pdf-engines#engines.
      def pdf_format format
        properties['pdfFormat'] = format

        self
      end

      # Merges the resulting PDFs.
      def merge
        properties['merge'] = true

        self
      end

      private

      def properties
        @properties ||= {}
      end
    end
  end
end