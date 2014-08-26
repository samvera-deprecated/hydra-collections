source 'https://rubygems.org'

# Specify your gem's dependencies in hydra-collections.gemspec
gemspec

gem 'active-fedora', github: 'projecthydra/active_fedora', ref: '331a64092daf3c2b5f72e32db750287f1f5bd198'
gem 'hydra-head', github: 'projecthydra/hydra-head', branch: 'fedora-4'
gem 'active-triples', github: 'no-reply/ActiveTriples'

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
