name 'nginx_conf'
maintainer 'Table XI'
maintainer_email 'sysadmins@tablexi.com'
license 'GNU Public License 3.0'
description 'Installs/Configures nginx_conf'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.1'

%w(ubuntu debian centos redhat amazon scientific oracle fedora).each do |os|
  supports os
end
