require 'liquid_stream'
require 'rspec'
require 'active_model'
require 'pry'
require 'capybara'
SPEC_DIR = File.expand_path(File.dirname(__FILE__))
Dir["#{SPEC_DIR}/fixtures/**/*.rb"].each {|f| require(f)}
Dir["#{SPEC_DIR}/support/**/*.rb"].each {|f| require(f)}

STREAM_CLASSES = [BlogStream, PostStream]

RSpec.configure do |config|
  config.order = 'random'

  config.before(:each) do
    STREAM_CLASSES.each(&:snapshot_streams!)
  end

  config.after(:each) do
    STREAM_CLASSES.each(&:restore_streams!)
  end
end
