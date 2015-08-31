action :create do
  listen = Array(new_resource.listen || node['nginx_conf']['listen'])
  locations = JSON.parse(node.send(new_resource.precedence)['nginx_conf']['locations'].to_hash.merge(new_resource.locations).to_json)
  options = JSON.parse(node.send(new_resource.precedence)['nginx_conf']['options'].to_hash.merge(new_resource.options).to_json)
  upstream = JSON.parse(node.send(new_resource.precedence)['nginx_conf']['upstream'].to_hash.merge(new_resource.upstream).to_json)
  server_name = new_resource.server_name || new_resource.name
  conf_name = new_resource.conf_name || new_resource.name
  site_type = new_resource.site_type
  socket = new_resource.socket
  nginx_group = (node['nginx']['group'] == node['nginx']['user']) ? 'root' : node['nginx']['group']
  ssl = false

  test_nginx = execute "test-nginx-conf-#{conf_name}-create" do
    action :nothing
    command "#{node['nginx']['binary']} -t"
    only_if { new_resource.auto_enable_site }
    notifies :restart, 'service[nginx]', new_resource.reload
  end

  if site_type == :dynamic
    locations.each do |name, _location|
      if options['try_files']
        options['try_files'] << " #{name}" if name.index('@') == 0
      end
    end

    if socket && locations.key?('/')
      locations['/']['proxy_pass'] = node['nginx_conf']['pre_socket'].to_s + socket.to_s
    end
  end

  if new_resource.ssl
    ssl_name = (new_resource.ssl['name']) ? new_resource.ssl['name'] : conf_name

    directory "#{node['nginx']['dir']}/ssl" do
      owner node['nginx']['user']
      group nginx_group
      mode '0755'
    end

    template "#{ssl_name}_public_crt" do
      path "#{node['nginx']['dir']}/ssl/#{ssl_name}.public.crt"
      source 'ssl.erb'
      cookbook 'nginx_conf'
      owner node['nginx']['user']
      group nginx_group
      mode '0640'
      variables(
        :ssl_key => new_resource.ssl['public']
      )
      notifies :run, test_nginx, new_resource.reload
    end

    template "#{ssl_name}_private_key" do
      path "#{node['nginx']['dir']}/ssl/#{ssl_name}.private.key"
      source 'ssl.erb'
      cookbook 'nginx_conf'
      owner node['nginx']['user']
      group nginx_group
      mode '0640'
      variables(
        :ssl_key => new_resource.ssl['private']
      )
      notifies :run, test_nginx, new_resource.reload
    end

    ssl = {
      :certificate => "#{node['nginx']['dir']}/ssl/#{ssl_name}.public.crt",
      :certificate_key => "#{node['nginx']['dir']}/ssl/#{ssl_name}.private.key"
    }
  end

  template "#{node['nginx']['dir']}/sites-available/#{conf_name}" do
    owner node['nginx']['user']
    group nginx_group
    mode '755'
    source(new_resource.template || 'conf.erb')
    cookbook new_resource.template ? new_resource.cookbook.to_s : 'nginx_conf'
    variables(
      :block => new_resource.block,
      :options => options,
      :upstream => upstream,
      :listen => listen,
      :locations => locations,
      :root => new_resource.root,
      :server_name => server_name,
      :type => site_type,
      :ssl => ssl
    )
    notifies :run, test_nginx, new_resource.reload
  end

  link "#{node['nginx']['dir']}/sites-enabled/#{conf_name}" do
    to "#{node['nginx']['dir']}/sites-available/#{conf_name}"
    only_if { new_resource.auto_enable_site }
    notifies :run, test_nginx, new_resource.reload
  end

  new_resource.updated_by_last_action(true)
end

action :delete do
  conf_name = new_resource.conf_name || new_resource.name

  link "#{node['nginx']['dir']}/sites-enabled/#{conf_name}" do
    to "#{node['nginx']['dir']}/sites-available/#{conf_name}"
    action :delete
  end

  file "#{node['nginx']['dir']}/sites-available/#{conf_name}" do
    action :delete
    notifies :restart, 'service[nginx]', new_resource.reload
  end

  if node['nginx_conf']['delete']['ssl']
    unless new_resource.ssl && !new_resource.ssl['delete']
      ssl_name =
      if new_resource.ssl && new_resource.ssl['name']
        new_resource.ssl['name']
      else
        conf_name
      end

      file "#{node['nginx']['dir']}/ssl/#{ssl_name}.public.crt" do
        action :delete
      end

      file "#{node['nginx']['dir']}/ssl/#{ssl_name}.private.key" do
        action :delete
      end
    end
  end

  new_resource.updated_by_last_action(true)
end

action :enable do
  conf_name = new_resource.conf_name || new_resource.name

  test_nginx = execute "test-nginx-conf-#{conf_name}-enable" do
    action :nothing
    command "#{node['nginx']['binary']} -t"
    notifies :restart, 'service[nginx]', new_resource.reload
  end

  link "#{node['nginx']['dir']}/sites-enabled/#{conf_name}" do
    to "#{node['nginx']['dir']}/sites-available/#{conf_name}"
    notifies :run, test_nginx, new_resource.reload
  end

  new_resource.updated_by_last_action(true)
end

action :disable do
  conf_name = new_resource.conf_name || new_resource.name

  link "#{node['nginx']['dir']}/sites-enabled/#{conf_name}" do
    to "#{node['nginx']['dir']}/sites-available/#{conf_name}"
    action :delete
    notifies :restart, 'service[nginx]', new_resource.reload
  end

  new_resource.updated_by_last_action(true)
end
