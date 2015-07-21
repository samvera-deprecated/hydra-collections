module Hydra
  module Collection
    extend ActiveSupport::Concern
    extend Deprecation
    include Hydra::Works::CollectionBehavior
    include Hydra::WithDepositor # for access to apply_depositor_metadata
    include Hydra::AccessControls::Permissions
    include Hydra::Collections::Metadata
    include Hydra::Works::CollectionBehavior
  end
end
