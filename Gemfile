source 'http://rubygems.org'

ruby File.open(File.expand_path('.ruby-version', File.dirname(__FILE__))) { |f| f.read.chomp }

gem 'berkshelf'
gem 'chef', '~> 13'
gem 'cookbook_release', git: 'git@github.com:tablexi/chef-cookbook_release_tasks.git'

group :dev do
  gem 'chef-validation'
  gem 'chefspec'
  gem 'foodcritic'
  gem 'rubocop'
end

group :guard do
  gem 'guard'
  gem 'guard-foodcritic'
  gem 'guard-kitchen'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'ruby_gntp'
end

group :kitchen do
  gem 'chef-zero'
  gem 'kitchen-docker'
  gem 'kitchen-ec2'
  gem 'test-kitchen'
end
