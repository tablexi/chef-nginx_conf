actions :create, :delete, :enable, :disable

default_action :create

attribute :block, :kind_of => [String, Array, NilClass] # Include additional code
attribute :cookbook, :kind_of => [String, NilClass], :default => "nginx_conf" #Cookbook to find template
attribute :listen, :kind_of => [String, NilClass]  # Listening port, ip, etc.
attribute :locations, :kind_of => [Hash, NilClass], :default => {} # Locations to include.
attribute :name, :name_attribute => true, :kind_of => String
attribute :options, :kind_of => [Hash, NilClass], :default => {} # Key value pairs of options to include in the Server body.
attribute :reload, :kind_of => [Symbol, NilClass], :default => :delayed # How soon should we restart nginx.
attribute :root, :kind_of => [String, NilClass] # Server root
attribute :server_name, :kind_of => [String, NilClass] # Server name if different then the name attribute.
attribute :socket, :kind_of => [String, NilClass] # Path to socket file.
attribute :template, :kind_of => [String, NilClass], :default => "conf.erb" # Template to use.
attribute :available_sites_repo, :kind_of => String, :default => "sites-available" # Relative path from node[nginx][dir] to the available sites folder
attribute :enabled_sites_repo, :kind_of => String, :default => "sites-enabled" # Relative path from node[nginx][dir] to the enabled sites folder 
attribute :auto_enable_site, :kind_of => Boolean, :default => true

def initialize(*args)
  super
  @action = :create
end
