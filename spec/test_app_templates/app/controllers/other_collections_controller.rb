class OtherCollectionsController < ApplicationController
  include Hydra::CollectionsControllerBehavior

  def show
    super
    redirect_to root_path
  end
end
