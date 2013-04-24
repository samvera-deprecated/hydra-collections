#!/usr/bin/env rake
require "bundler/gem_tasks"

Dir.glob('tasks/*.rake').each { |r| import r }

ENV["RAILS_ROOT"] ||= 'spec/internal'

desc 'Run CI tests in e.g. Travis environment'
task :travis => ['clean', 'ci']

desc 'Default: run CI'
task :default => [:travis]
