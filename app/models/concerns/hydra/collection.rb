module Hydra
  module Collection
    extend ActiveSupport::Concern
    extend Deprecation
    include Hydra::WithDepositor # for access to apply_depositor_metadata
    include Hydra::AccessControls::Permissions
    include Hydra::Collections::Collectible
    include Hydra::Collections::Metadata
    include Hydra::Collections::Relations

    def update_all_members
      Deprecation.warn(Collection, 'update_all_members is deprecated and will be removed in version 5.0')
      self.members.collect { |m| update_member(m) }
    end

    # TODO: Use solr atomic updates to accelerate this process
    def update_member member
      Deprecation.warn(Collection, 'update_member is deprecated and will be removed in version 5.0')
      # because the member may have its collections cached, reload that cache so that it indexes the correct fields.
      member.collections(true) if member.respond_to? :collections
      member.update_index
    end

    def add_members new_member_ids
      return if new_member_ids.nil? || new_member_ids.size < 1
      self.members << ActiveFedora::Base.find(new_member_ids)
    end
 end
end
