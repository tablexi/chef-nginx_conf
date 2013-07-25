name			 "nginx_conf"
maintainer       "Firebelly Design"
maintainer_email "lloyd@firebellydesign.com"
license          "GNU Public License 3.0"
description      "Installs/Configures nginx_conf"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.1"

depends 'nginx'

%w{ ubuntu debian centos redhat amazon scientific oracle fedora }.each do |os|
  supports os
end
