module Hydra
  module Collections
    extend ActiveSupport::Autoload
    autoload :Version
    autoload :Collectible
    class Engine < ::Rails::Engine
      engine_name "collections"
    end
  end
end
