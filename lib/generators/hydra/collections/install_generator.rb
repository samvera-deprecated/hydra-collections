require 'rails/generators'

module Hydra::Collections
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc 'This generator makes the following changes to your application:
   1. Creates a collection model.
'

    def collection
      copy_file "collection.rb", "app/models/collection.rb"
    end
  end
end
