include_recipe 'fake::helper'

nginx_conf_file 'testapp1'

nginx_conf_file 'testapp2' do
  block 'testblock1'
end