service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action :start
end