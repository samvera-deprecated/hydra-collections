#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

ENV["RAILS_ROOT"] ||= 'spec/internal'

desc 'Default: run specs.'
task :default => :spec


task :spec => [:generate] do |t|
  focused_spec = ENV['SPEC'] ? " SPEC=#{File.join(GEM_ROOT, ENV['SPEC'])}" : ''
  within_test_app do
    system "rake myspec#{focused_spec}"
    abort "Error running hydra-collections" unless $?.success?
  end
end



desc "Create the test rails app"
task :generate do
  unless File.exists?('spec/internal/Rakefile')
    puts "Generating rails app"
    `rails new spec/internal`
    puts "Copying gemfile"
    `cp spec/support/Gemfile spec/internal`
    puts "Copying generator"
    `cp -r spec/support/lib/generators spec/internal/lib`

    within_test_app do
      puts "Bundle install"
      puts `bundle install`
      puts "running generator"
      puts `rails generate test_app`

      puts "running migrations"
      puts `rake db:migrate db:test:prepare`
    end
  end
  puts "Running specs"
end

desc "Clean out the test rails app"
task :clean do
  puts "Removing sample rails app"
  `rm -rf spec/internal`
end

def within_test_app
  FileUtils.cd('spec/internal')
  Bundler.with_clean_env do
    yield
  end
  FileUtils.cd('../..')
end
