# Copyright © 2013 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe CollectionsSearchHelper do
  before do
    @collection = Collection.create(title: "Title of Collection 1")
    class CollectionWithMetadata < ActiveFedora::Base
      include Hydra::Collection
      def to_solr(solr_doc={})
        super
        solr_doc[Solrizer.solr_name(:title, :displayable)] = self.descMetadata.title
        solr_doc
      end
    end
    @collection_with_metadata = CollectionWithMetadata.create(title: "Title of Collection 2")
  end
  describe "collection_name" do
    it "should return the pid if no title available" do
      collection_name(@collection.pid).should == @collection.pid
    end
    it "should return the title value associated with the given pid" do
      collection_name(@collection_with_metadata.pid).should == "Title of Collection 2"
    end
  end
  describe "display_value_for_facet" do
    it "should look up collection_name when displaying collection facet" do
      display_value_for_facet(Solrizer.solr_name(:collection, :facetable), @collection_with_metadata.pid).should == "Title of Collection 2"
    end
  end
end