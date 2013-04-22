# -*- encoding : utf-8 -*-
module Hydra
  module Collections
    class Routes

      def initialize(router, options)
        @router = router
        @options = options
      end

      def draw
        add_routes do |options|
          resources :collections, :except=>:index 
        end
      end

      protected

      def add_routes &blk
        @router.instance_exec(@options, &blk)
      end
    end
  end
end

