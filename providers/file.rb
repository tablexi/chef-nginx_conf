action :create do
  listen = new_resource.listen || node['nginx_conf']['listen']
  locations = node.send(new_resource.precedence)['nginx_conf']['locations'].to_hash.merge(new_resource.locations)
  options = node.send(new_resource.precedence)['nginx_conf']['options'].to_hash.merge(new_resource.options)
  server_name = new_resource.server_name || new_resource.name
  type = :dynamic
  proxy_pass = false
  ssl = false

  if type == :dynamic
    locations.each do |name, location|
      proxy_pass = true if location['proxy_pass']
      if options['try_files']
        options['try_files'] << " #{name}" if name.index('@') == 0
      end
    end
  end

  if new_resource.socket && locations.has_key?('/')
    locations['/']['proxy_pass'] = node['nginx_conf']['pre_socket'].to_s + new_resource.socket
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

    file "#{node['nginx']['dir']}/ssl/#{server_name}.public.crt" do
      owner node['nginx']['user'] 
      group node['nginx']['group']
      mode "0640"
      content new_resource.ssl['public']
    end

    file "#{node['nginx']['dir']}/ssl/#{server_name}.private.key" do
      owner node['nginx']['user'] 
      group node['nginx']['group']
      mode "0640"
      content new_resource.ssl['private']
    end

    ssl = {
      :certificate => "#{node['nginx']['dir']}/ssl/#{server_name}.public.crt",
      :certificate_key => "#{node['nginx']['dir']}/ssl/#{server_name}.private.key"
    }
    listen = '443 ssl' if listen == '80'
  end

  template "#{node['nginx']['dir']}/sites-available/#{server_name}" do
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

  nginx_site "#{server_name}" do
    action :enable
    only_if { new_resource.auto_enable_site }
  end

  new_resource.updated_by_last_action(true)
end

action :delete do
  server_name = new_resource.server_name || new_resource.name

  nginx_site "#{server_name}" do
    action :disable
  end

  template "#{node['nginx']['dir']}/sites-available/#{server_name}" do
    action :delete
    notifies :restart, resources(:service => "nginx"), new_resource.reload
  end

  new_resource.updated_by_last_action(true)
end

action :enable do
  server_name = new_resource.server_name || new_resource.name

  link "#{node['nginx']['dir']}/sites-enabled/#{server_name}" do
    to "#{node['nginx']['dir']}/sites-available/#{server_name}"
  end

  execute "test-nginx-conf" do
    command "nginx -t"
    notifies :restart, resources(:service => "nginx"), new_resource.reload
  end

  new_resource.updated_by_last_action(true)
end

action :disable do
  server_name = new_resource.server_name || new_resource.name

  nginx_site "#{server_name}" do
    action :disable
  end

  new_resource.updated_by_last_action(true)
end