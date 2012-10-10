#
# Cookbook Name:: nginx_conf
# Recipe:: default
#
# Copyright 2012, Firebelly Design
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
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