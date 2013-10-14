include_recipe 'fake::helper'

nginx_conf_file 'testapp1' do
  action :delete
end

nginx_conf_file 'testapp2' do
  action :delete
  ssl({'delete' => false})
end