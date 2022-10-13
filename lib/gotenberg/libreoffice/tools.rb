require 'gotenberg/utilities/index'

module Gotenberg
  class Libreoffice
    module Tools

     # Converts the given document(s) to PDF(s).
     # Gotenberg will return either a unique PDF if you request a merge or a ZIP archive with the PDFs.
     # Note: if you requested a merge, the merging order is determined by the order of the arguments.
     # See https://gotenberg.dev/docs/modules/libreoffice#route.
      def convert *sources
        sources.each.with_index(1) do |source, index|
          io, filename = load_file_from_source(source)

          files << multipart_file(io, merge_prefix(index) + filename)
        end

        @endpoint = '/forms/libreoffice/convert'

        self
      end

      private

      def zip_mode?
        properties['merge'] != true && files.size > 1
      end

      def merge_prefix number
        properties['merge'] ? Gotenberg::Utilities::Index::to_alpha(number) + '_' : ''
      end
    end
  end
end