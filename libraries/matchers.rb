if defined?(ChefSpec)
  def create_nginx_conf(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nginx_conf, :create, resource_name)
  end

  def delete_nginx_conf(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nginx_conf, :delete, resource_name)
  end

  def enable_nginx_conf(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nginx_conf, :enable, resource_name)
  end

  def disable_nginx_conf(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nginx_conf, :disable, resource_name)
  end
end
