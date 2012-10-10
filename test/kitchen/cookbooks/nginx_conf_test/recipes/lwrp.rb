# test/kitchen/cookbooks/recipes/nginx_conf_test/lwrp.rb

nginx_conf_file "test5.mywebsite.com" do
  socket "/var/www/myapp/shared/tmp/sockets/unicorn.socket"
end

nginx_conf_file "test6.mywebsite.com" do
  root "/var/www/myapp"
end

nginx_conf_file "test7.mywebsite.com" do
  action :disable
end

nginx_conf_file "test8.mywebsite.com" do
  action :delete
end