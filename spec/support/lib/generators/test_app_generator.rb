require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../../support", __FILE__)

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)       

    generate 'blacklight', '--devise'
  end

  def run_hydra_head_generator
    say_status("warning", "GENERATING HH", :yellow)       

    generate 'hydra:head', '-f'
  end

  # Inject call to Hydra::Collections.add_routes in config/routes.rb
  def inject_routes
    insert_into_file "config/routes.rb", :after => '.draw do' do
      "\n  # Add Collections routes."
      "\n  Hydra::Collections.add_routes(self)"
    end
  end

  def copy_rspec_rake_task
    copy_file "lib/tasks/rspec.rake"
  end

  def copy_hydra_config
    copy_file "config/initializers/hydra_config.rb"
  end
end
