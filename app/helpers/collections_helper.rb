# View Helpers for Hydra Batch Edit functionality
module CollectionsHelper 
  
 
  # Displays the Collections create collection button.  Put this in your search result page template.  We recommend putting it in catalog/_sort_and_per_page.html.erb
  def button_for_create_collection(label = 'Create Collection')
    render :partial=>'/collections/button_create_collection', :locals=>{:label=>label}
  end
  
end
