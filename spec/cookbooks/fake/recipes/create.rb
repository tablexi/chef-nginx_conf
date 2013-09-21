include_recipe 'fake::helper'

# basic setup
nginx_conf_file 'testapp1'

nginx_conf_file 'testapp2' do
  block 'testblock1'
end

# ssl
nginx_conf_file 'testapp3' do
  ssl({'public' => 'crt', 'private' => 'key'})
end

nginx_conf_file 'testapp4' do
  ssl({'public' => 'testapp4_crt', 'private' => 'testapp4_key', 'name' => 'test-ssl'})
end

nginx_conf_file 'testapp5' do
  ssl({'public' => 'testapp4_crt', 'private' => 'testapp4_key', 'name' => 'test-ssl'})
end