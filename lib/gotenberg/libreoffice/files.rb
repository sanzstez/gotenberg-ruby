require 'faraday'
require 'faraday/multipart'
require 'gotenberg/utilities/index'

module Gotenberg
  class Libreoffice
    module Files

     # Converts the given document(s) to PDF(s).
     # Gotenberg will return either a unique PDF if you request a merge or a ZIP archive with the PDFs.
     # Note: if you requested a merge, the merging order is determined by the order of the arguments.
     # See https://gotenberg.dev/docs/modules/libreoffice#route.
      def convert *sources
        sources.each.with_index(1) do |source, index|
          files << multipart_file(IO.binread(source), merge_prefix(index) + File.basename(source))
        end

        @endpoint = '/forms/libreoffice/convert'

        self
      end

      private

      def files
        @files ||= []
      end

      def zip_mode?
        properties['merge'] != true && files.size > 1
      end

      def merge_prefix number
        properties['merge'] ? Gotenberg::Utilities::Index::to_alpha(number) + '_' : ''
      end

      def multipart_file body, filename, content_type = 'application/octet-stream'
        Faraday::Multipart::FilePart.new(StringIO.new(body), content_type, filename)
      end
    end
  end
end