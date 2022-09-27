require 'json'
require 'gotenberg/analyzers/image'
require 'gotenberg/analyzers/js'
require 'gotenberg/analyzers/css'

module Gotenberg
  class Compiler
    CONTEXT_TAG_REGEX = /(<!-- GOTENBERG-CONTEXT-TAG (.+) -->)/.freeze

    attr_accessor :html

    def initialize html
      @html = html
    end

    def body
      @body ||= compile_body(html)
    end

    def assets
      @assets ||= []
    end

    private

    def compile_body body
      body.gsub(CONTEXT_TAG_REGEX) do |context_tag|
        resource = JSON.parse($2, symbolize_names: true)

        analyzer = 
          case resource[:tag]
          when 'image'
            Analyzers::Image.new(resource).call
          when 'js'
            Analyzers::Js.new(resource).call
          when 'css'
            Analyzers::Css.new(resource).call
          end

        assets.push(*analyzer.assets)

        analyzer.tag
      end
    end
  end
end