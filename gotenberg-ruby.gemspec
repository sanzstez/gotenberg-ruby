require_relative 'lib/gotenberg/version'

Gem::Specification.new do |s|
  s.name = 'gotenberg-ruby'
  s.summary = s.description = 'A gem that provides a client interface for the Gotenberg PDF generate service'
  s.authors = ['sanzstez']
  s.email = ['sanzstez@gmail.com']
  s.homepage = 'https://github.com/sanzstez/gotenberg-ruby'
  s.license = 'MIT'

  s.version = Gotenberg::VERSION
  s.platform = Gem::Platform::RUBY

  s.add_dependency 'faraday', '>= 2.0.0'
  s.add_dependency 'faraday-multipart', '>= 1.0.4'
  s.add_dependency 'mini_exiftool', '>= 1.0.0'
  s.add_dependency 'launchy', '>= 2.2', '< 3'

  s.files = Dir['lib/**/*', 'README.md', 'LICENSE.md']
end