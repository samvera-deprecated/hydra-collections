module Hydra
  module Collections
    extend ActiveSupport::Autoload
    autoload :Version
    class Engine < ::Rails::Engine
      engine_name "collections"
    end
  end
end
