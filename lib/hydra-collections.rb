require "hydra/head"
require 'hydra/works'

module Hydra
  module Collections
    extend ActiveSupport::Autoload
    autoload :Version
    autoload :Collectible
    autoload :SearchService
    autoload :AcceptsBatches
    autoload :SelectsCollections
    autoload :SolrDocumentBehavior
    autoload :SearchBehaviors
    class Engine < ::Rails::Engine
      engine_name "collections"
      config.autoload_paths += %W(
        #{config.root}/app/controllers/concerns
        #{config.root}/app/models/concerns
        #{config.root}/app/models/datastreams
      )
    end
  end
end
