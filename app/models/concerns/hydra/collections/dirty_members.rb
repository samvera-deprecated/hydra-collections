module Hydra
  module Collections
    module DirtyMembers
      extend ActiveSupport::Concern

      def member_ids= new_members
        @old_member_ids = member_ids
        super
      end

      def changed_member_ids
        @old_member_ids || []
      end

      def removed_members
        changed_member_ids - member_ids
      end

    end
  end
end
