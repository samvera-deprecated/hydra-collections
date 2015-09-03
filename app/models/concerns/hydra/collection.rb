module Hydra
  module Collection
    extend ActiveSupport::Concern
    extend Deprecation
    include Hydra::Works::CollectionBehavior
    include Hydra::WithDepositor # for access to apply_depositor_metadata
    include Hydra::AccessControls::Permissions
    include Hydra::Collections::Metadata
    include Hydra::Works::CollectionBehavior


    def add_members new_member_ids
      return if new_member_ids.nil? || new_member_ids.size < 1
      new_member_ids.each do |id|
        collection.child_generic_works << ActiveFedora::Base.find(id)
      end
      #TODO this old way was more efficient #collection.member_ids = batch.concat(collection.member_ids)
    end

  end
end
