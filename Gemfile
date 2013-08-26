source 'https://rubygems.org'

gem 'chef',       ENV['CHEF_VERSION'] || '~> 11.0.0'

group :test do
  gem 'chefspec',
    :git => "git://github.com/acrmp/chefspec.git"
  gem 'strainer',
    '>= 2.0.0'
  gem 'foodcritic'
  gem 'gherkin',
    '<= 2.11.6'
  gem 'berkshelf',
    '~> 1.0'
end
