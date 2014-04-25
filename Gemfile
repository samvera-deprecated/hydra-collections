source 'https://rubygems.org'

# Specify your gem's dependencies in hydra-collections.gemspec
gemspec

gem 'active-fedora', github: 'projecthydra/active_fedora', branch: 'fedora-4'
gem 'hydra-head', github: 'psu-stewardship/hydra-head', branch: 'fedora-4'


group :development, :test do
  gem 'sqlite3'
  gem "factory_girl_rails"
  gem 'devise'
  gem 'capybara'
  gem 'jettywrapper'
  gem 'byebug', require: false
end

file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path("../spec/internal", __FILE__))
if File.exists?(file)
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
end
