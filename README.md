# Hydra::Collections

TODO: Write a gem description

## Code Status

[![Build Status](https://travis-ci.org/psu-stewardship/hydra-collections.png?branch=master)](https://travis-ci.org/psu-stewardship/hydra-collections)
[![Dependencies Status](https://gemnasium.com/psu-stewardship/hydra-collections.png)](https://gemnasium.com/psu-stewardship/hydra-collections)

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

### Call collections_add_collection view helper in your search result page template.
  We recommend putting it in catalog/_sort_and_per_page.html.erb which you will manually override in you app.

    <%= collections_add_collection %>

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
