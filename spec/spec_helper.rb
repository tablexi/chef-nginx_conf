require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.platform = 'amazon'
  config.version = '2018.03'
  config.log_level = :fatal
end
