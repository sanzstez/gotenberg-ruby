require 'launchy'

module Gotenberg
  class Backtrace
    attr_accessor :files

    def initialize files
      @files = files
    end

    def call
      return unless index_available?

      FileUtils.mkdir_p(backtrace_location)

      files.each do |file|
        File.open(File.join(backtrace_location, file.original_filename), 'wb') do |f|
          f << file.io.read
        end

        file.io.rewind
      end

      ::Launchy.open(File.join(backtrace_location, 'index.html'))
    end

    private

    def index_available?
      files.any? { |f| f.original_filename == 'index.html' }
    end

    def backtrace_location
      @backtrace_location ||= File.join(
        Gotenberg.configuration.backtrace_dir,
        "#{Time.now.to_f.to_s.tr('.', '_')}_#{rand(0x100000000).to_s(36)}"
      )
    end
  end
end