require 'mini_exiftool'
require 'tempfile'

module Gotenberg
  class Exiftools
    attr_reader :io, :metadata

    def self.modify io, metadata
      new(io, metadata).call
    end

    def initialize io, metadata
      @io = io
      @metadata = metadata
    end

    def call
      set_attributes
      write

      @body
    end

    def exiftools
      @exiftools ||= MiniExiftool.new(tempfile.path)
    end

    private

    def set_attributes
      metadata.each do |property, v|
        exiftools.public_send(('%s=' % property), v)
      end
    end

    def write
      exiftools.save!

      @body = tempfile.read
    rescue StandardError => e
      raise e
    ensure
      tempfile.close
      tempfile.unlink
    end

    def tempfile
      @tempfile ||= tempfile_builder do |file|
        file << io
      end
    end

    def tempfile_builder
      Tempfile.new(['gootenberg', '.pdf']).tap do |tempfile|
        tempfile.binmode
        yield tempfile if block_given?
        tempfile.rewind
      end
    end
  end
end