require 'chef/util/file_edit'
require 'yaml'

action :create do
  listen = new_resource.listen || node['nginx_conf']['listen']
  locations = node['nginx_conf']['locations'].to_hash.merge(new_resource.locations)
  options = node['nginx_conf']['options'].to_hash.merge(new_resource.options)
  server_name = new_resource.server_name || new_resource.name
  type = :dynamic
  proxy_pass = false
  enabled_sites_dirpath = new_resource.enabled_sites_repo || (node['nginx']['dir'] || "") + "/sites-enabled"
  available_sites_dirpath = new_resource.available_sites_repo || (node['nginx']['dir'] || "") + "/sites-available"

  if type == :dynamic
    locations.each do |name, location|
      proxy_pass = true if location['proxy_pass']
      if options['try_files']
        options['try_files'] << " #{name}" if name.index('@') == 0
      end
    end
  end

  if new_resource.socket && locations.has_key?('/')
    locations['/']['proxy_pass'] = node['nginx_conf']['pre_socket'] + new_resource.socket
  elsif !proxy_pass
    type = :static
  end

  execute "test-nginx-conf" do
    command "nginx -t"
    action :nothing
    #notifies :restart, resources(:service => "nginx"), new_resource.reload
  end

  if new_resource.auto_enable_site
    nginx_conf_file new_resource.name do
      action :enable
      available_sites_repo new_resource.available_sites_repo
      enabled_sites_repo new_resource.enabled_sites_repo
    end
  end

  template "#{available_sites_dirpath}/#{new_resource.name}" do
    owner "root"
    group "root"
    mode "755"
    source new_resource.template
    cookbook new_resource.cookbook
    variables(
      :block =>  new_resource.block,
      :options =>  options,
      :listen => listen,
      :locations =>  locations,
      :root =>  new_resource.root,
      :server_name => server_name,
      :type =>  type
    )
    #notifies :create, resources(:link => "#{enabled_sites_dirpath}/#{new_resource.name}"), :immediately
  end

  new_resource.updated_by_last_action(true)
end

action :delete do
  link "#{enabled_sites_dirpath}/#{new_resource.name}" do
    action :delete
    to "#{node['nginx']['dir']}/sites-available/#{new_resource.name}"
    #notifies :restart, resources(:service => "nginx"), new_resource.reload
  end

  template "#{available_sites_dirpath}/#{new_resource.name}" do
    action :delete
  end

  new_resource.updated_by_last_action(true)
end

action :enable do
  enabled_sites_dirpath = node['nginx']['dir'] + '/' + new_resource.enabled_sites_repo
  available_sites_dirpath = node['nginx']['dir'] + '/' + new_resource.available_sites_repo

  link "#{enabled_sites_dirpath}/#{new_resource.name}" do
    action :nothing
    to "#{available_sites_dirpath}/#{new_resource.name}"
    notifies :run, resources(:execute => "test-nginx-conf"), :immediately
  end
end

action :disable do
  enabled_sites_dirpath = node['nginx']['dir'] + '/' + new_resource.enabled_sites_repo
  available_sites_dirpath = node['nginx']['dir'] + '/' + new_resource.available_sites_repo

  link "#{enabled_sites_dirpath}/#{new_resource.name}" do
    action :delete
    to "#{available_sites_dirpath}/#{new_resource.name}"
    notifies :restart, resources(:service => "nginx"), new_resource.reload
  end

  new_resource.updated_by_last_action(true)
end