require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../../support", __FILE__)

  # Inject call to Hydra::Collections.add_routes in config/routes.rb
  def inject_routes
    insert_into_file "config/routes.rb", :after => '.draw do' do
      "\n  # Add Collections routes."
      "\n  Hydra::Collections.add_routes(self)"
    end
  end

  def copy_test_models
    copy_file "app/models/sample.rb"
    copy_file "app/models/solr_document.rb"
    copy_file "db/migrate/20111101221803_create_searches.rb"
  end

  def copy_rspec_rake_task
    copy_file "lib/tasks/rspec.rake"
  end

  def copy_hydra_config
    copy_file "config/initializers/hydra_config.rb"
  end
end
