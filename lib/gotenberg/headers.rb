require 'json'

module Gotenberg
  module Headers
    # Sets the callback and error callback that Gotenberg will use to send
    # respectively the output file and the error response.
    def webhook url, error_url
      headers['Gotenberg-Webhook-Url'] = url
      headers['Gotenberg-Webhook-Error-Url'] = error_url

      self
    end

    # Overrides the default HTTP method that Gotenberg will use to call the webhook.
    # Either "POST", "PATCH", or "PUT" - default "POST".
    def webhook_method method
      headers['Gotenberg-Webhook-Method'] = method

      self
    end

    # Overrides the default HTTP method that Gotenberg will use to call the error webhook.
    # Either "POST", "PATCH", or "PUT" - default "POST".
    def webhook_error_method method
      headers['Gotenberg-Webhook-Error-Method'] = method

      self
    end

    # Sets the extra HTTP headers that Gotenberg will send alongside the request to the webhook and error webhook.
    def webhook_extra_http_headers headers
      headers['Gotenberg-Webhook-Extra-Http-Headers'] = headers.to_json

      self
    end

    # Overrides the default UUID trace, or request ID, that identifies a request in Gotenberg's logs.
    def trace trace, header = 'Gotenberg-Trace'
      headers[header] = trace

      self
    end

    private

    def webhook_request?
      headers.keys.include?('Gotenberg-Webhook-Url')
    end

    def headers
      @headers ||= {}
    end
  end
end