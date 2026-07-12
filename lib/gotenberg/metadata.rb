require 'json'

module Gotenberg
  module Metadata
    def meta elements
      metadata.merge!(elements)
      properties['metadata'] = metadata.to_json unless metadata.empty?

      self
    end

    private

    def metadata
      @metadata ||= {}
    end
  end
end
