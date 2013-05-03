# Hydra::Collections [![Version](https://badge.fury.io/rb/hydra-collections.png)](http://badge.fury.io/rb/hydra-collections) [![Build Status](https://travis-ci.org/psu-stewardship/hydra-collections.png?branch=master)](https://travis-ci.org/psu-stewardship/hydra-collections) [![Dependency Status](https://gemnasium.com/psu-stewardship/hydra-collections.png)](https://gemnasium.com/psu-stewardship/hydra-collections)

Add collections to your Hydra application

## Installation

Add this line to your application's Gemfile:

    gem 'hydra-collections'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hydra-collections

## Usage

### Mount the engine to get the routes in config/routes.rb

    mount Hydra::Collections::Engine => '/' 

### Call button_create_collection view helper in your search result page template.
  We recommend putting it in catalog/_sort_and_per_page.html.erb which you will manually override in you app.

    <%= button_create_collection %>

### Any time you want to refer to the routes from hydra-collections use collections.
    collections.new_collections_path

### Make your Models Collectible

Add `include Hydra::Collections::Collectible` to the models for anything that you want to be able to add to collections (ie. GenericFile, Book, Article, etc.), then add `index_collection_pids` to the solrization logic (ie. put it in to_solr)

Example:
```ruby
class GenericFile < ActiveFedora::Base
  include Hydra::Collections::Collectible
  ...
  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    index_collection_pids(solr_doc)
    return solr_doc
  end
end
```

Any items that include the `Hydra::Collections::Collectible` module can look up which collections they belong to via `.collections`.  The `index_collection_pids` puts the pids of all associated collections into the `collection` facet.

### Make your Controller Accept a Batch

Add `include Hydra::Collections::AcceptsBatches` to the collections you would like to process batches of models

You can access the batch in your update.

Example:
```ruby
class BatchEditsController < ApplicationController
    include Hydra::Collections::AcceptsBatches
  ...
  
    def update
      batch.each do |doc_id|
        obj = ActiveFedora::Base.find(doc_id, :cast=>true)
        update_document(obj)
        obj.save
      end
      flash[:notice] = "Batch update complete"
      after_update 
    end

end
```
### Include the javascript to discover checked batch items

include `//= require hydra/batch_select` in your application.js

### Display a selection checkbox in each document partial

include `<%= button_for_add_to_batch document %>'

Example: views/catalog/_document_header.html.erb
```ruby
    <% # header bar for doc items in index view -%>
    <div class="documentHeader clearfix">
      <%= button_for_add_to_batch(document) %>
      
      ...
     </div>

```


### Update your view to submit a Batch

include 
Add `submits-batches` class to your view input to initialize batch processing

Example: 
```ruby
<%= button_to label, edit_batch_edits_path, :method=>:get, :class=>"btn submits-batches", 'data-behavior'=>'batch-edit', :id=>'batch-edit' %>
```

### Update you action view to submit changes to the batch

Add `updates-batches` class to your 


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Setup instructions for Contributors

In order to make modifications to the gem code and run the tests, clone the repository then

```
    $ bundle install
    $ git submodule init
    $ git submodule update
    $ rake jetty:config
    $ rake jetty:start
    $ rake clean 
    $ rake spec
```


