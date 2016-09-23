[![Circle CI](https://circleci.com/gh/tablexi/chef-nginx_conf.svg?style=svg)](https://circleci.com/gh/tablexi/chef-nginx_conf)
#Description#

Manage nginx server configuration files.




#Requirements#
 * Chef >= 11.0
 * Nginx cookbook - As of version 2.0.0, we no longer require the nginx cookbook explicitly. You can use whatever means to install nginx. The only requirement is a Chef service resource called nginx be made available to this cookbook.


#Attributes#

See a list of all [attributes](https://github.com/firebelly/chef-nginx_conf/tree/master/attributes/default.rb).


#Usage#


Add the `nginx_conf` recipe to your runlist.


##confs##

Rather then accessing the LWRP directly, add a site hash to the `confs` attribute list.

    node['nginx_conf']['confs'] = [{
      'test1.mywebsite.com' => {
        'socket' => "/var/www/myapp/shared/tmp/sockets/unicorn.socket"
      },
      'test2.mywebsite.com' => {
        'root' => "/var/www/myapp",
        'site_type' => :static
      },
      'test3.mywebsite.com' => {
        'action' => :disable
      },
      'test4.mywebsite.com' => {
        'action' => :delete
      },
    }]

##Create##

Creates a nginx configuration in the sites-available directory, tests it, symlinks to sites-enabled, and restarts nginx.  See a list of all [LWRP attributes](https://github.com/firebelly/chef-nginx_conf/tree/master/resources/file.rb).

    nginx_conf_file "mywebsite.com" do
      socket "/var/www/myapp/shared/tmp/sockets/unicorn.socket"
    end

Outputs to sites-available/mywebsite.com:

    server {
      listen 80;

      server_name mywebsite.com;

      location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://unix:/var/www/myapp/shared/tmp/sockets/unicorn.socket;
      }
    }

Creating a static conf is even easier.

    nginx_conf_file "mywebsite.com" do
      root "/var/www/myapp"
      site_type :static
    end

Outputs to sites-available/mywebsite.com:

    server {
      listen 80;

      server_name mywebsite.com;

      root "/var/www/myapp";
    }

###SSL

To configure ssl:

    nginx_conf_file "mywebsite.com" do
      ssl({'public' => 'public_key', 'private' => 'private_key', 'name' => 'mywebsite'})
    end

*NOTE* The name attribute is optional.  It defaults to the resource conf_name or resource name. It is only necessary, if you want to define the public and private key file name.  EXE Using the value above, the file names would be mywebsite.public.crt & mywebsite.private.key respectively.


##Disable##

Removes the symlink between sites-enabled and sites-available for the named configuration.

    nginx_conf_file "mywebsite.com" do
      action :disable
    end

##Delete##

Removes the symlink and deletes the configuration:

    nginx_conf_file "mywebsite.com" do
      action :delete
    end

###SSL Delete

Deleting SSL certs is managed by the delete resource, but there are some situations where you want to manage the deletion yourself.  To do this, set the `[:nginx_conf][:defaults][:delete][:ssl]` to false or add :delete false to the nginx_conf_file ssl attribute hash.

    nginx_conf_file "mywebsite.com" do
      action :delete
      ssl({'delete' => false})
    end


#Testing#

We use foodcritic and chefspec to check basic functionality.  To run tests:

    bundle install
    berks install
    strainer test
