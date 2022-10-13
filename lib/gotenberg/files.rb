require 'faraday'
require 'faraday/multipart'

module Gotenberg
  module Files

    private

    def files
      @files ||= []
    end

    def load_file_from_source source
      io, filename = 
        case source
        when String
          [IO.binread(source), File.basename(source)]
        when Array
          source
        end

      [io, filename]
    end

    def multipart_file body, filename, content_type = 'application/octet-stream'
      Faraday::Multipart::FilePart.new(StringIO.new(body), content_type, filename)
    end
  end
end