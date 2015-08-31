actions :create, :delete, :enable, :disable

default_action :create

attribute :block, :kind_of => [String, Array, NilClass], :default => nil # Include additional code
attribute :cookbook, :kind_of => [String, NilClass], :default => nil # Cookbook to find template
attribute :listen, :kind_of => [String, Array, NilClass], :default => nil # Listening port, ip, etc.
attribute :locations, :kind_of => [Hash, NilClass], :default => {} # Locations to include.
attribute :name, :name_attribute => true, :kind_of => String
attribute :options, :kind_of => [Hash, NilClass], :default => {} # Key value pairs of options to include in the Server body.
attribute :upstream, :kind_of => [Hash, NilClass], :default => {} # Key value pair of upstream configuration to include outside Server body.
attribute :reload, :equal_to => [:delayed, :immediately, 'delayed', 'immediately'], :default => :delayed # How soon should we restart nginx.
attribute :root, :kind_of => [String, NilClass], :default => nil # Server root
attribute :server_name, :kind_of => [String, Array, NilClass], :default => nil # Server name if different then the name attribute.
attribute :conf_name, :kind_of => [String, NilClass], :default => nil # Configuration name.
attribute :socket, :kind_of => [String, NilClass], :default => nil # Path to socket file.
attribute :template, :kind_of => [String, NilClass], :default => nil # Template to use.
attribute :auto_enable_site, :kind_of => [TrueClass, FalseClass], :default => true # Define if you want to link your newly created site conf from sites-availables to sites-enabled
attribute :ssl, :kind_of => [Hash, NilClass], :default => nil # Allow the creation of ssl cert files.
attribute :precedence, :default => :default # Level of attribute precedence to use
attribute :site_type, :equal_to => [:dynamic, :static, 'dynamic', 'static'], :default => :dynamic

def initialize(*args)
  super
  @action = :create
end
