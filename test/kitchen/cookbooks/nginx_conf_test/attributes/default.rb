include_attribute "nginx_conf::default"
node.set['nginx_conf']['confs'] = [{
  'test1.mywebsite.com' => {
    'socket' => "/var/www/myapp/shared/tmp/sockets/unicorn.socket"
  },
  'test2.mywebsite.com' => {
    'root' => "/var/www/myapp"
  },
  'test3.mywebsite.com' => {
    'action' => :disable
  },
  'test4.mywebsite.com' => {
    'action' => :delete
  },
}]