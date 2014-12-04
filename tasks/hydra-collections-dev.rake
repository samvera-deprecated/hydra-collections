require 'rspec/core'
require 'rspec/core/rake_task'
require 'jettywrapper'
require 'engine_cart/rake_task'

Jettywrapper.hydra_jetty_version = "v8.1.0"

RSpec::Core::RakeTask.new(:spec)

desc 'Spin up hydra-jetty and run specs'
task ci: ['engine_cart:clean', 'engine_cart:generate', 'jetty:clean'] do
  puts 'running continuous integration'
  jetty_params = Jettywrapper.load_config
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end
