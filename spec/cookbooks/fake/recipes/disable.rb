service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action :start
end

nginx_conf_file 'testapp1' do
  action :disable
end