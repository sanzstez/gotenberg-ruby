module Gotenberg
  module Metadata
    # set meta headers for PDF file with exiftools (title, creator, etc...)
    def meta elements
      metadata.merge!(elements)

      self
    end

    private

    def metadata_available?
      !metadata.empty?
    end

    def metadata
      @metadata ||= {}
    end
  end
end