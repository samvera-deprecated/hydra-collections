class Collection < ActiveFedora::Base
  include Hydra::Collection

  # You can replace these metadata if they're not suitable
  include Hydra::Collections::BasicMetadata
end

