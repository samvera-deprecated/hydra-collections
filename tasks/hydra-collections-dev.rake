require 'rspec/core'
require 'rspec/core/rake_task'
require 'jettywrapper'
require 'engine_cart/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ['--backtrace'] if ENV['CI']
end

desc 'Spin up hydra-jetty and run specs'
task ci: ['engine_cart:clean', 'engine_cart:generate', 'jetty:clean'] do
  puts 'running continuous integration'
  jetty_params = Jettywrapper.load_config
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end
