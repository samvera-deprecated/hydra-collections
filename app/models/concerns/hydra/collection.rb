module Hydra
  module Collection
    extend ActiveSupport::Concern
    extend Deprecation
    include Hydra::Works::CollectionBehavior
    include Hydra::WithDepositor # for access to apply_depositor_metadata
    include Hydra::AccessControls::Permissions
    include Hydra::Collections::RequiredMetadata
    include Hydra::Works::CollectionBehavior


    def add_members new_member_ids
      return if new_member_ids.nil? || new_member_ids.empty?
      self.members << ActiveFedora::Base.find(new_member_ids)
    end

  end
end
