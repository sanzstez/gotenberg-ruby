require 'gotenberg/version'
require 'gotenberg/railtie' if defined?(Rails::Railtie)

module Gotenberg
  autoload :Chromium, 'gotenberg/chromium'
end