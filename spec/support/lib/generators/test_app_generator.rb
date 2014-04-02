require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../../support", __FILE__)

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)       

    generate "blacklight:install", '--devise'
  end

  def run_hydra_head_generator
    say_status("warning", "GENERATING HH", :yellow)       

    generate 'hydra:head', '-f'
  end
  
  def run_migrations
    rake("db:migrate")
  end

  # Inject call to Hydra::Collections.add_routes in config/routes.rb
  def inject_routes
    insert_into_file "config/routes.rb", :after => '.draw do' do
      "\n  # Add Collections routes."
      "\n  mount Hydra::Collections::Engine => '/'"
    end
  end

  def copy_rspec_rake_task
    copy_file "lib/tasks/rspec.rake"
  end

  def delete_generated_noise
    remove_file("public/index.html")
    remove_file("spec/models/user_spec.rb")
  end
  
  def copy_view_overrides
    directory("app/views/catalog")
  end
  
  # Inject javascript into application.js
  def inject_javascript
    insert_into_file "app/assets/javascripts/application.js", :after => '//= require_tree .' do
      "\n   //include javascript for batches and collections\n//= require hydra/batch_select\n//=  require hydra_collections"
    end
  end

  # Inject javascript into application.js
  def inject_css
    insert_into_file "app/assets/stylesheets/application.css", :after => '*= require_tree .' do
      "\n  *= require hydra_collections"
    end
  end
  
  # Inject collections call into balacklight catalog
  def inject_collections
    insert_into_file "app/controllers/catalog_controller.rb", :after => 'Hydra::Controller::ControllerBehavior' do
      "\n  include Hydra::Collections::SelectsCollections\n  before_filter :find_collections, :only=>:index"
    end
  end

  # Inject collections SolrDocumentBehavior into balacklight SolrDocument
  def inject_solr_doc
    insert_into_file "app/models/solr_document.rb", :after => 'include Blacklight::Solr::Document' do
      "\n      # Adds Collection behaviors to the SolrDocument.\n      include Hydra::Collections::SolrDocumentBehavior"
    end
  end

  def add_create_permissions
    insert_into_file 'app/models/ability.rb', after: 'custom_permissions' do
          "\n    can :create, :all if user_groups.include? 'registered'\n"
    end
  end
end
