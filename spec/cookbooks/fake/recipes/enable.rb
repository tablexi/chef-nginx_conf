include_recipe 'fake::helper'

nginx_conf_file 'testapp1' do
  action :enable
end