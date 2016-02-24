if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
else
  require 'byebug'
end

ENV["RAILS_ENV"] ||= 'test'

require 'engine_cart'
EngineCart.load_application!

require 'rspec/rails'
require 'hydra-collections'

FactoryGirl.definition_file_paths = [File.expand_path("../factories", __FILE__)]
FactoryGirl.find_definitions

# require 'http_logger'
# HttpLogger.logger = Logger.new(STDOUT)
# HttpLogger.ignore = [/localhost:8983\/solr/]
# HttpLogger.colorize = false

require 'active_fedora/cleaner'
RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include Devise::TestHelpers, :type => :controller
  config.infer_spec_type_from_file_location!
  config.before(:each) do
    ActiveFedora::Cleaner.clean!
  end

  config.include Warden::Test::Helpers
  config.before :suite do
    Warden.test_mode!
  end

  config.after :each do
    Warden.test_reset!
  end
end

module FactoryGirl
  def self.find_or_create(handle, by=:email)
    tmpl = FactoryGirl.build(handle)
    tmpl.class.send("find_by_#{by}".to_sym, tmpl.send(by)) || FactoryGirl.create(handle)
  end
end

