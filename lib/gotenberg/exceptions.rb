module Gotenberg
  class TransformError < StandardError
    RESPONSE_ATTRIBUTES = %i[
      response
      response_status
      response_headers
      response_body
    ].freeze

    attr_reader :original_error

    def initialize(original_error = nil)
      @original_error = original_error
      super
    end

    RESPONSE_ATTRIBUTES.each do |attribute|
      define_method attribute do
        original_error.public_send(attribute) if original_error.respond_to?(attribute)
      end
    end
  end

  class RemoteSourceError < StandardError; end
end
