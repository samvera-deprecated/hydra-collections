require 'rspec/core'
require 'rspec/core/rake_task'
require 'solr_wrapper'
require 'fcrepo_wrapper'
require 'engine_cart/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ['--backtrace'] if ENV['CI']
end

desc 'Start solr, fcrepo, and run specs'
task ci: ['engine_cart:generate'] do
  puts 'running continuous integration'
  # setting port: nil assigns a random port.
  # TODO: set port to nil (random)
  solr_params = { port: '8985', verbose: true, managed: true }
  fcrepo_params = { port: '8986', verbose: true, managed: true,
                    no_jms: true, fcrepo_home_dir: 'fcrepo4-test-data' }
  SolrWrapper.wrap(solr_params) do |solr|
    ENV['SOLR_TEST_PORT'] = solr.port
    solr.with_collection(name: 'hydra-test', dir: File.join(File.expand_path("..", File.dirname(__FILE__)), "solr", "config")) do
      FcrepoWrapper.wrap(fcrepo_params) do |fcrepo|
        ENV['FCREPO_TEST_PORT'] = fcrepo.port
        Rake::Task['spec'].invoke
      end
    end
  end
end
