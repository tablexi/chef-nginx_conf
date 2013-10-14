require 'chefspec'

def chef_run(opts = {})
  cookbook_paths = [
    File.expand_path('../../..', __FILE__),
    File.expand_path('../cookbooks', __FILE__)
  ]

  options = {
    :step_into => ['nginx_conf_file'],
    :environment => 'production',
    :cookbook_path => cookbook_paths,
    :log_level => :fatal
  }.merge(opts)
  
  @chef_run = ChefSpec::Runner.new(options) do |node|
    env = Chef::Environment.new
    env.name options[:environment]

    # Stub the node to return this environment
    node.stub(:chef_environment).and_return env.name

    # Stub any calls to Environment.load to return this environment
    Chef::Environment.stub(:load).and_return env
    node.automatic_attrs[:platform_family] = 'rhel'
    node.automatic_attrs[:platform] = 'amazon'
  end
end