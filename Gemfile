source 'http://rubygems.org'

ruby File.open(File.expand_path('.ruby-version', File.dirname(__FILE__))) { |f| f.read.chomp }

gem 'berkshelf'

group :dev do
  gem 'foodcritic'
  gem 'chefspec'
  gem 'rubocop'
  gem 'stove'
end

group :kitchen do
  gem 'test-kitchen'
  gem 'chef-zero'
  gem 'kitchen-vagrant'
end

group :guard do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-foodcritic'
  gem 'guard-rubocop'
  gem 'guard-kitchen'
  gem 'ruby_gntp'
end
