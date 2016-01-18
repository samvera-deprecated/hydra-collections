require "hydra/head"

module Hydra
  module Collections
    extend ActiveSupport::Autoload
    autoload :Version
    autoload :Collectible
    autoload :SearchService
    autoload :AcceptsBatches

    class Engine < ::Rails::Engine
      engine_name "collections"
    end
  end
end
