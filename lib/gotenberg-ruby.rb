require 'gotenberg/version'
require 'gotenberg/railtie' if defined?(Rails::Railtie)

module Gotenberg
  autoload :Chromium, 'gotenberg/chromium'
  autoload :Libreoffice, 'gotenberg/libreoffice'
  autoload :PdfEngines, 'gotenberg/pdf_engines'
  autoload :Exiftools, 'gotenberg/exiftools'
  autoload :Configuration, 'gotenberg/configuration'

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end