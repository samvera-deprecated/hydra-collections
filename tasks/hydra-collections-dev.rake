require 'rspec/core'
require 'rspec/core/rake_task'
require 'jettywrapper'
require 'engine_cart/rake_task'

JETTY_ZIP_BASENAME = 'fedora-4b1'
Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/#{JETTY_ZIP_BASENAME}.zip"

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

EXTRA_GEMS =<<EOF
gem 'active-fedora', github: 'projecthydra/active_fedora', branch: 'fedora-4'
gem 'hydra-head', github: 'projecthydra/hydra-head', branch: 'fedora-4'

EOF

namespace :engine_cart do
  # we're adding some extra stuff into the gemfile beyond what engine_cart gives us by default
  task :inject_gemfile_extras do
    open(File.expand_path('Gemfile', EngineCart.destination), 'a') do |f|
      f.write EXTRA_GEMS
    end
  end
end
