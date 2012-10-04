[![Build Status](https://secure.travis-ci.org/firebelly/chef-nginx_conf.png)](http://travis-ci.org/firebelly/chef-nginx_conf)

#Description#

Manage nginx server configuration files.


#Requirements#
 
 * Nginx recipe.


#Attributes#

See a list of all [attributes](https://github.com/firebelly/chef-nginx_conf/tree/master/attributes/default.rb).


#Usage#

##Create##

Creates a nginx configuration in the sites-available directory, tests it, symlinks to sites-enabled, and restarts nginx.  The only required attribute is root.  See a list of all [LWRP attributes](https://github.com/firebelly/chef-nginx_conf/tree/master/resources/file.rb).

  $ nginx_conf_file "mywebsite.com" do
  $   root "/var/www/myapp"
  $   socket "/var/www/myapp/shared/tmp/sockets/unicorn.socket"
  $ end

Outputs to sites-available/mywebsite.com:
  
  server {
    listen 80;

    server_name mywebsite.com;

    client_max_body_size 20M;
    keepalive_timeout 5;
    try_files $uri/index.html $uri.html $uri @proxy;

    location @proxy {
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $http_host;
      proxy_redirect off;
      proxy_pass http://unix:/var/www/myapp/shared/tmp/sockets/unicorn.socket;
    }
  }

Creating a static conf is even easier.
  
  $ nginx_conf_file "mywebsite.com" do
  $   root "/var/www/myapp"
  $ end

Outputs to sites-available/mywebsite.com:
    
  server {
    listen 80;

    server_name mywebsite.com;

    client_max_body_size 20M;
    keepalive_timeout 5;
    
    try_files $uri/index.html $uri.html $uri;
  }

##Disable##

Removes the symlink between sites-enabled and sites-available for the named configuration.

  $ nginx_conf_file "mywebsite.com" do
  $   action :disable
  $ end

##Delete##

Removes the symlink and deletes the configuration:

  $ nginx_conf_file "mywebsite.com" do
  $   action :delete
  $ end