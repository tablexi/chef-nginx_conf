# test/kitchen/cookbooks/recipes/nginx_conf_test/setup.rb

include_recipe('nginx::default')

['test3.mywebsite.com', 'test4.mywebsite.com', 'test7.mywebsite.com', 'test8.mywebsite.com'].each do |site|
  file "#{node['nginx']['dir']}/sites-available/#{site}" do
    action :touch
    owner "root"
    group "root"
    mode "755"
  end

  link "#{node['nginx']['dir']}/sites-enabled/#{site}" do
    to "#{node['nginx']['dir']}/sites-available/#{site}"
  end
end