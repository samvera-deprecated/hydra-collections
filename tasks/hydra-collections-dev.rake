require 'rspec/core'
require 'rspec/core/rake_task'
require 'solr_wrapper'
require 'fcrepo_wrapper'
require 'engine_cart/rake_task'
require 'active_fedora/rake_support'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ['--backtrace'] if ENV['CI']
end

desc 'Start solr, fcrepo, and run specs'
task ci: ['engine_cart:generate'] do
  puts 'running continuous integration'
  with_test_server do
    Rake::Task['spec'].invoke
  end
end
