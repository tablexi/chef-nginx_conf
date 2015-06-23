#
# Cookbook Name:: nginx_conf
# Library:: default
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

# Helper function for displaying configuration options.
def nginx_conf_options(options, level = 0, type = false)
  output = []
  options.each do |option, value|
    if type
      output << _nginx_conf_type(type, option, value, level)
    elsif value.is_a?(Hash)
      output << _nginx_conf_hash(option, value, level)
    elsif value.is_a?(Array)
      output << _nginx_conf_array(option, value, level)
    else
      output << _nginx_conf_string(option, value, level)
    end
  end
  output.join("\n")
end

def _nginx_conf_array(option, value, level)
  output = []
  value.each do |v|
    output << nginx_conf_options({ option => v }, level)
  end
  output
end

def _nginx_conf_hash(option, value, level)
  indent = '  ' * level
  output = []
  if ['locations', 'if', 'upstream', 'limit_except'].include? option
    output << nginx_conf_options(value, level, option)
  else
    value.each do |k, v|
      output << "#{indent}#{option} #{k} #{v};"
    end
  end
  output
end

def _nginx_conf_string(option, value, level)
  indent = '  ' * level
  output = []
  if option == 'block'
    output << "#{indent}#{value};"
  else
    output << "#{indent}#{option} #{value};"
  end
  output
end

def _nginx_conf_type(type, option, value, level)
  indent = '  ' * level
  <<-CFG

#{_nginx_conf_types(type, indent, option)}
#{nginx_conf_options(value, level + 1)}
#{indent}}
CFG
end

def _nginx_conf_types(type, indent, option)
  case type
  when 'locations'
    "#{indent}location #{option} {"
  when 'if'
    "#{indent}if (#{option}) {"
  else
    "#{indent}#{type} #{option} {"
  end
end
