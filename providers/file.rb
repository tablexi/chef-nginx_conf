require 'chef/util/file_edit'
require 'yaml'

action :create do
  listen = new_resource.listen || node['nginx_conf']['listen'].to_str
  locations = JSON.parse(node['nginx_conf']['locations'].to_json).merge(new_resource.locations)
  options = node['nginx_conf']['options'].to_hash.merge(new_resource.options)
  server_name = new_resource.server_name || new_resource.name
  type = :dynamic
  proxy_pass = false
  ssl = false
  enabled_sites_dirpath = new_resource.enabled_sites_repo || "#{node['nginx']['dir']}/sites-enabled"
  available_sites_dirpath = new_resource.available_sites_repo || "#{node['nginx']['dir']}/sites-available"

  if type == :dynamic
    locations.each do |name, location|
      proxy_pass = true if location['proxy_pass']
      if options['try_files']
        options['try_files'] << " #{name}" if name.index('@') == 0
      end
    end
  end

  if new_resource.socket && locations.has_key?('/')
    locations['/']['proxy_pass'] = node['nginx_conf']['pre_socket'].to_str + new_resource.socket
  elsif !proxy_pass
    type = :static
  end

  if new_resource.ssl
    # Make sure nginx is being compiled with ssl support
    include_recipe('nginx::http_ssl_module')

    directory "#{node['nginx']['dir']}/ssl" do
      owner node['nginx']['user'] 
      group node['nginx']['group']
      mode "0755"
    end

    file "#{nginx_root}/ssl/#{new_resource.name}.public.crt" do
      owner node['nginx']['user'] 
      group node['nginx']['group']
      mode "0640"
      content new_resource.ssl['public']
    end

    file "#{nginx_root}/ssl/#{new_resource.name}.private.key" do
      owner node['nginx']['user'] 
      group node['nginx']['group']
      mode "0640"
      content new_resource.ssl['private']
    end

    ssl = {
      :certificate => "#{nginx_root}/ssl/#{new_resource.name}.public.crt",
      :certificate_key => "#{nginx_root}/ssl/#{new_resource.name}.private.key"
    }
    listen = '443 ssl' if listen == '80'
  end

  template "#{available_sites_dirpath}/#{new_resource.name}" do
    owner node['nginx']['user'] 
    group node['nginx']['group']
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
      :type =>  type,
      :ssl => ssl
    )
  end

  nginx_conf_file "#{new_resource.name}_enable" do
    action :enable
    server_name new_resource.name
    available_sites_repo available_sites_dirpath
    enabled_sites_repo enabled_sites_dirpath
    only_if { new_resource.auto_enable_site }
  end

  new_resource.updated_by_last_action(true)
end

action :delete do
  enabled_sites_dirpath = new_resource.enabled_sites_repo || "#{node['nginx']['dir']}/sites-enabled"
  available_sites_dirpath = new_resource.available_sites_repo || "#{node['nginx']['dir']}/sites-available"
  server_name = new_resource.server_name || new_resource.name

  link "#{enabled_sites_dirpath}/#{server_name}" do
    action :delete
    to "#{available_sites_dirpath}/#{server_name}"
    only_if { available_sites_dirpath != enabled_sites_dirpath }
  end

  template "#{available_sites_dirpath}/#{server_name}" do
    action :delete
    notifies :restart, resources(:service => "nginx"), new_resource.reload
  end

  new_resource.updated_by_last_action(true)
end

action :enable do
  enabled_sites_dirpath = new_resource.enabled_sites_repo || "#{node['nginx']['dir']}/sites-enabled"
  available_sites_dirpath = new_resource.available_sites_repo || "#{node['nginx']['dir']}/sites-available"
  server_name = new_resource.server_name || new_resource.name

  link "#{enabled_sites_dirpath}/#{server_name}" do
    to "#{available_sites_dirpath}/#{server_name}"
    only_if { available_sites_dirpath != enabled_sites_dirpath }
  end

  execute "test-nginx-conf" do
    command "nginx -t"
    notifies :restart, resources(:service => "nginx"), new_resource.reload
  end

  new_resource.updated_by_last_action(true)
end

action :disable do
  enabled_sites_dirpath = new_resource.enabled_sites_repo || "#{node['nginx']['dir']}/sites-enabled"
  available_sites_dirpath = new_resource.available_sites_repo || "#{node['nginx']['dir']}/sites-available"

  link "#{enabled_sites_dirpath}/#{new_resource.name}" do
    action :delete
    to "#{available_sites_dirpath}/#{new_resource.name}"
    only_if { available_sites_dirpath != enabled_sites_dirpath }
    notifies :restart, resources(:service => "nginx"), new_resource.reload
  end

  new_resource.updated_by_last_action(true)
end