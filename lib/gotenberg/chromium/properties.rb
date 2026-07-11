require 'json'

module Gotenberg
  class Chromium
    module Properties

      # Define whether to print the entire content in one single page
      def single_page
        properties['singlePage'] = true
      end

      # Overrides the default paper size, in inches. Examples of paper size (width x height):
      # Letter - 8.5 x 11 (default)
      # Legal - 8.5 x 14
      # Tabloid - 11 x 17
      # Ledger - 17 x 11
      # A0 - 33.1 x 46.8
      # A1 - 23.4 x 33.1
      # A2 - 16.54 x 23.4
      # A3 - 11.7 x 16.54
      # A4 - 8.27 x 11.7
      # A5 - 5.83 x 8.27
      # A6 - 4.13 x 5.83
      def paper_size width, height
        properties['paperWidth'] = width
        properties['paperHeight'] = height

        self
      end

      # Overrides the default margins (i.e., 0.39), in inches.
      def margins top: nil, bottom: nil, left: nil, right: nil
        properties['marginTop'] = top if top
        properties['marginBottom'] = bottom if bottom
        properties['marginLeft'] = left if left
        properties['marginRight'] = right if right

        self
      end

      # Forces page size as defined by CSS.
      def prefer_css_page_size
        properties['preferCssPageSize'] = true

        self
      end

      # Prints the background graphics.
      def print_background
        properties['printBackground'] = true

        self
      end

      # Sets the paper orientation to landscape.
      def landscape
        properties['landscape'] = true

        self
      end

      # Overrides the default scale of the page rendering (i.e., 1.0).
      def scale scale
        properties['scale'] = scale

        self
      end

      # Set the page ranges to print, e.g., "1-5, 8, 11-13". Empty means all pages.
      def native_page_ranges ranges
        properties['nativePageRanges'] = ranges

        self
      end

      # Sets the duration (i.e., "1s", "2ms", etc.) to wait when loading an HTML document before converting it to PDF.
      def wait_delay delay
        properties['waitDelay'] = delay

        self
      end

      # Sets the JavaScript expression to wait before converting an HTML document to PDF until it returns true.
      # For instance: "window.status === 'ready'".
      def wait_for_expression expression
        properties['waitForExpression'] = expression

        self
      end

      # Waits for the network to be idle before converting an HTML document to PDF.
      # https://gotenberg.dev/docs/routes#performance-mode-chromium
      def wait_for_network_idle
        properties['skipNetworkIdleEvent'] = false # default is true

        self
      end

      # DEPRECATED in Gotenberg 8. Overrides the default "User-Agent" header.
      def user_agent user_agent
        properties['userAgent'] = user_agent

        self
      end

      # Sets extra HTTP headers that Chromium will send when loading the HTML document.
      def extra_http_headers headers
        properties['extraHttpHeaders'] = headers.to_json

        self
      end

      # Forces Gotenberg to return a 409 Conflict response if there are exceptions in the Chromium console
      def fail_on_console_exceptions
        properties['failOnConsoleExceptions'] = true

        self
      end

      # Forces Chromium to emulate the media type "print" or "screen".
      def emulate_media_type type
        properties['emulatedMediaType'] = type

        self
      end

      # Sets the PDF format of the resulting PDF.
      # See https://gotenberg.dev/docs/modules/pdf-engines#engines.
      def pdf_format format
        properties['pdfFormat'] = format

        self
      end

      # Converts a target URL to PDF.
      # See https://gotenberg.dev/docs/modules/chromium#url.
      def url url, extra_link_tags = [], extra_script_tags = []
        links = extra_link_tags.flat_map { |url| { 'href' => url } }
        scripts = extra_script_tags.flat_map { |url| { 'src' => url } }

        properties['url'] = url
        properties['extraLinkTags'] = links.to_json
        properties['extraScriptTags'] = scripts.to_json

        @endpoint = '/forms/chromium/convert/url'

        self
      end

      private

      def properties
        @properties ||= {}
      end
    end
  end
end
