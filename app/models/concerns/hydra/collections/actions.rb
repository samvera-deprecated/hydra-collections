module Hydra::Collections
  module Actions
    extend ActiveSupport::Concern

    included do
      before_create :set_date_uploaded
      before_save :set_date_modified
    end

    private

      def set_date_uploaded
        self.date_uploaded = Date.today
      end

      def set_date_modified
        self.date_modified = Date.today
      end
  end
end

