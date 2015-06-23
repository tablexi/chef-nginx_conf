require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.platform = 'amazon'
  config.version = '2014.03'
  config.log_level = :fatal
end
