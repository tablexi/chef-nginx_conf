[![Build Status](https://travis-ci.org/firebelly/chef-nginx_conf.png)](https://travis-ci.org/firebelly/chef-nginx_conf)
#Description#

Manage nginx server configuration files.


#Requirements#
 * Chef >= 11.0
 * Nginx cookbook


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


#Testing#

We use foodcritic and chefspec to check basic functionality.  To run tests:

    bundle install
    berks install
    strainer test