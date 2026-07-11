module Gotenberg
  class Configuration
    attr_accessor :backtrace_dir, :html_debug, :vite_output_dir, :vite_source_code_dir

    def initialize
      @backtrace_dir =
        if defined?(Rails) && Rails.respond_to?(:root)
          Rails.root.join('tmp', 'gotenberg')
        else
          Dir.mktmpdir
        end

      @vite_output_dir = 'tmp/vite-pdf'
      @vite_source_code_dir = 'app/javascript'

      @html_debug = false
    end
  end
end
