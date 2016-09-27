require File.expand_path('../lib/rspec/sidekiq/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'rspec-sidekiq'
  s.version     = RSpec::Sidekiq::VERSION
  s.platform    = Gem::Platform::RUBY
  s.author      = 'Phil Ostler'
  s.email       = 'github@philostler.com'
  s.homepage    = 'http://github.com/philostler/rspec-sidekiq'
  s.summary     = 'RSpec for Sidekiq'
  s.description = 'Simple testing of Sidekiq jobs via a collection of matchers and helpers'
  s.license     = 'MIT'

  s.add_dependency 'rspec', '~> 3.0', '>= 3.0.0'
  s.add_dependency 'sidekiq', '>= 2.4.0'
  s.add_dependency 'rspec-rails', '>= 3.4.0'

  s.add_development_dependency 'coveralls', '~> 0.8', '>= 0.8.0'
  s.add_development_dependency 'fuubar', '~> 2.0', '>= 2.0.0'
  s.add_development_dependency 'activejob', '~> 4.2', '>= 4.0.0'
  s.add_development_dependency 'actionmailer', '~> 4.2', '>= 4.0.0'


  s.files = Dir['.gitattributes'] +
            Dir['.gitignore'] +
            Dir['.rspec'] +
            Dir['.simplecov'] +
            Dir['.travis'] +
            Dir['CHANGES.md'] +
            Dir['Gemfile'] +
            Dir['LICENSE'] +
            Dir['README.md'] +
            Dir['rspec-sidekiq.gemspec'] +
            Dir['**/*.rb']
  s.require_paths = ['lib']
end
