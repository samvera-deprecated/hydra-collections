source 'https://rubygems.org'

# Specify your gem's dependencies in hydra-collections.gemspec
gemspec

group :development, :test do
  gem 'sqlite3'
  gem "factory_girl_rails"
  gem 'devise'
  gem 'capybara'
  gem 'jettywrapper'
  gem 'byebug', require: false unless ENV['CI']
  gem 'coveralls', require: false
  gem 'rspec-activemodel-mocks'
end

gem 'slop', '~> 3.6' # because rails installs byebug in the Gemfile

file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path("../spec/internal", __FILE__))
if File.exists?(file)
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
else
  extra_file = File.expand_path("../spec/test_app_templates/Gemfile.extra", __FILE__)
  instance_eval File.read(extra_file)

  gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']

  if ENV['RAILS_VERSION'] and ENV['RAILS_VERSION'] !~ /^4.2/
    gem 'sass-rails', "< 5.0"
  else
    gem 'responders', "~> 2.0"
    gem 'sass-rails', ">= 5.0"
  end
end
