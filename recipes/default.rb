#
# Cookbook Name:: nginx_conf
# Recipe:: default
#
# Copyright 2012, FIREBELLY DESIGN
#
# All rights reserved - Do Not Redistribute
#

Array(node['nginx_conf']['confs']).each do |site|
  site.each do |name,options|
    conf = {
      'action' => :create,
      'cookbook' => nil,
      'block' => nil,
      'listen' => nil,
      'locations' => nil,
      'options' => nil,
      'reload' => nil,
      'root' => nil,
      'server_name' => nil,
      'socket' => nil,
      'template' => nil
    }.merge(options)

    nginx_conf_file name do
      action conf['action']
      cookbook conf['cookbook']
      block conf['block']
      listen conf['listen']
      locations conf['locations']
      options conf['options']
      reload conf['reload']
      root conf['root']
      server_name conf['server_name']
      socket conf['socket']
      template conf['template']
    end
  end
end