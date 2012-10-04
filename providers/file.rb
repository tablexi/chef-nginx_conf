require 'chef/util/file_edit'

action :create do
  locations = node['nginx_conf']['locations'].merge(new_resource.locations)
  options = node['nginx_conf']['options'].merge(new_resource.options)  
  server_name = new_resource.server_name || new_resource.name
  try_files = options['try_files']
  type = :dynamic

  if new_resource.socket
    locations['@proxy']['proxy_pass'] = "#{node['nginx_conf']['pre_socket']}#{new_resource.socket}"
  elsif !locations['@proxy']['proxy_pass']
    type = :static
  end

  if type == :dynamic
    locations.each do |name, location|
      try_files << " #{name}" if name.index('@') == 0
    end
  end

  template "#{node['nginx']['dir']}/sites-available/#{new_resource.name}" do
    owner "root"
    group "root"
    mode "0755"
    source new_resource.template
    cookbook new_resource.cookbook
    variables(
      :block =>  new_resource.block,
      :options =>  options,
      :locations =>  locations,
      :root =>  new_resource.root,
      :server_name => server_name,
      :try_files => try_files,
      :type =>  type
    )
    notifies :create, resources(:link => "#{node['nginx']['dir']}/sites-enabled/#{new_resource.name}"), :immediately
  end

  link "#{node['nginx']['dir']}/sites-enabled/#{new_resource.name}" do
    action :nothing
    to "#{node['nginx']['dir']}/sites-available/#{new_resource.name}"
    notifies :restart, resources(:service => "nginx"), new_resource.reload
    only_if do
      # This seems hacky, but how else can you test the conf before creating the symlink.
      FileUtils.mkdir_p('/tmp/nginx')
      FileUtils.cp([File.join(node['nginx']['dir'], 'nginx.conf'), File.join(node['nginx']['dir'], 'sites-available', new_resource.name)], '/tmp/nginx')

      nginx_conf = Chef::Util::FileEdit.new("/tmp/nginx/nginx.conf")
      nginx_conf.search_file_replace_line(/include .*\/conf.d\/\*.conf;/, "include /tmp/nginx/#{new_resource.name};")
      nginx_conf.search_file_delete_line(/include .*\/sites-enabled\/\*;/)
      nginx_conf.write_file

      `nginx -t -c /tmp/nginx/nginx.conf`;  result=$?.success?

      FileUtils.remove_dir('/tmp/nginx')

      result
    end
  end
  new_resource.updated_by_last_action(true)
end

action :delete do
  link "#{node['nginx']['dir']}/sites-enabled/#{new_resource.name}" do
    action :delete
    to "#{node['nginx']['dir']}/sites-available/#{new_resource.name}"
    notifies :restart, resources(:service => "nginx"), new_resource.reload
  end

  template "#{node['nginx']['dir']}/sites-available/#{new_resource.name}" do
    action :delete
  end
  new_resource.updated_by_last_action(true)
end

action :disable do
  link "#{node['nginx']['dir']}/sites-enabled/#{new_resource.name}" do
    action :delete
    to "#{node['nginx']['dir']}/sites-available/#{new_resource.name}"
    notifies :restart, resources(:service => "nginx"), new_resource.reload
  end
  new_resource.updated_by_last_action(true)
end