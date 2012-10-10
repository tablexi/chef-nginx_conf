default['nginx_conf']['confs'] = []
default['nginx_conf']['listen'] = '80'
default['nginx_conf']['pre_socket'] = 'http://unix:'
default['nginx_conf']['options'] = {}
default['nginx_conf']['locations'] = {
  '/' => {
    'proxy_set_header' => {
      'X-Forwarded-For' => '$proxy_add_x_forwarded_for',
      'Host' => '$http_host'
    },
    'proxy_redirect' => 'off',
    'proxy_pass' => nil
  }
}