$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("config/environment", ENV['RAILS_ROOT'] || File.expand_path("../internal", __FILE__))
require 'rspec/rails'
require 'hydra-collections'

FactoryGirl.definition_file_paths = [File.expand_path("../factories", __FILE__)]
FactoryGirl.find_definitions

# HttpLogger.logger = Logger.new(STDOUT)
# HttpLogger.ignore = [/localhost:8983\/fedora/]

module EngineRoutes
  def self.included(base)
    base.routes { Hydra::Collections::Engine.routes }
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include Devise::TestHelpers, :type => :controller
  config.before(:each, type: "controller") { @routes = Hydra::Collections::Engine.routes }
  config.include EngineRoutes, :type => :controller
  config.infer_spec_type_from_file_location!
  # Stub out test stuff.
  config.before(:each) do
    begin
      ActiveFedora.fedora.connection.delete(ActiveFedora.fedora.base_path.sub('/', ''))
    rescue StandardError
    end
    ActiveFedora.fedora.connection.put(ActiveFedora.fedora.base_path.sub('/', ''),"")
    restore_spec_configuration if ActiveFedora::SolrService.instance.nil? || ActiveFedora::SolrService.instance.conn.nil?
    ActiveFedora::SolrService.instance.conn.delete_by_query('*:*', params: {'softCommit' => true})
  end
end

module FactoryGirl
  def self.find_or_create(handle, by=:email)
    tmpl = FactoryGirl.build(handle)
    tmpl.class.send("find_by_#{by}".to_sym, tmpl.send(by)) || FactoryGirl.create(handle)
  end
end

