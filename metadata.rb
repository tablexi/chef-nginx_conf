name 'nginx_conf'
maintainer 'Table XI'
maintainer_email 'sysadmins@tablexi.com'
license 'GPL-3.0'
description 'Installs/Configures nginx_conf'
issues_url 'https://github.com/tablexi/chef-nginx_conf/issues'
source_url 'https://github.com/tablexi/chef-nginx_conf'
version_file = File.join(File.dirname(__FILE__), 'VERSION')
version File.exist?(version_file) ? IO.read(version_file) : '0.0.0'

chef_version '>= 12'

%w(ubuntu debian centos redhat amazon scientific oracle fedora).each do |os|
  supports os
end
