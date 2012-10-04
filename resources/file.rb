action :create, :delete, :disable

default_action :create

attribute :cookbook, :kind_of => String, :default => "nginx_conf" #Cookbook to find template
attribute :block, :kind_of => [String, Array] # Include additional code
attribute :listen, :kind_of => String, :default => node['nginx_conf']['listen']  # Listening port, ip, etc.
attribute :locations, :kind_of => Hash, :default => {} # Locations to include.
attribute :name, :name_attribute => true, :kind_of => String
attribute :options, :kind_of => Hash, :default => {} # Key value pairs of options to include in the Server body.
attribute :reload, :default => :delayed # How soon should we restart nginx.
attribute :root, :kind_of => String # Server root
attribute :server_name, :kind_of => String # Server name if different then the name attribute.
attribute :socket, :kind_of => String # Path to socket file.
attribute :template, :kind_of => String, :default => "conf.erb" # Template to use.

def initialize(*args)
  super
  @action = :create
end