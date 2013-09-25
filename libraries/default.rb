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
def nginx_conf_options(options, level=0, type=false)
  indent = '  ' * level
  output = []
  options.each do |option,value|
    if type == 'locations'
      output << <<-CFG

#{indent}location #{option} {
#{nginx_conf_options(value,level+1)}
#{indent}}
CFG
    elsif type == 'if'
      output << <<-CFG

#{indent}if (#{option}) {
#{nginx_conf_options(value,level+1)}
#{indent}}
CFG
    elsif type == 'upstream'
      output << <<-CFG

#{indent}upstream #{option} {
#{nginx_conf_options(value,level+1)}
#{indent}}
CFG
    elsif type == 'limit_except'
      output << <<-CFG

#{indent}limit_except #{option} {
#{nginx_conf_options(value,level+1)}
#{indent}}
CFG
    else
      if value.kind_of?(Hash)
        if ['locations', 'if', 'upstream','limit_except'].include? option
          output << nginx_conf_options(value, level, option)
        else
          value.each do |k,v|
            output << "#{indent}#{option} #{k} #{v};"
          end
        end
      elsif value.kind_of?(Array)
        value.each do |v|
          output << nginx_conf_options({option => v}, level)
        end
      else
        if option == 'block'
          output << "#{indent}#{value};"
        else
          output << "#{indent}#{option} #{value};"
        end
      end
    end
  end
  output.join("\n")
end
