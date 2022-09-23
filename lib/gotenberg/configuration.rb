module Gotenberg
  class Configuration
    attr_accessor :backtrace_dir, :html_debug

    def initialize
      @backtrace_dir = if defined?(Rails)
        Rails.root.join('tmp', 'gotenberg')
      else
        Dir.mktmpdir
      end

      @html_debug = false
    end
  end
end
