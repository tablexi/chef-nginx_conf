require_relative 'spec_helper'

describe 'nginx_conf::default' do
  before do
    @chef_run = chef_run()
  end

  describe 'attributes' do
  	before do
  	  @chef_run.node[:nginx_conf][:confs] = {
  	  	'testapp1' => {
  	  	  'block' => 'testapp1 block',
  	  	  'cookbook' => 'testapp1 cookbook',
  	  	  'listen' => '80',
  	  	  'locations' => {
  	  	  	'/' => {
  	  	  	  'testapp1' => 'locations'
  	  	  	}
  	  	  },
  	  	  'options' => {
  	  	  	'testapp1' => 'options'
  	  	  },
  	  	  'upstream' => {
  	  	  	'testapp1' => 'upstream'
  	  	  },
  	  	  'reload' => :immediately,
  	  	  'root' => '/root/testapp1',
  	  	  'server_name' => 'http://testapp1.server_name',
  	  	  'conf_name' => 'testapp1.conf',
  	  	  'socket' => '/tmp/socket'
  	  	},
  	  	'testapp2' => {
  	  	  'block' => ['testapp2', 'block'],
  	  	  'listen' => ['80', '81'],
  	  	  'server_name' => [
  	  	  	'http://testapp2.server_name',
  	  	  	'http://testapp2.server_name'
  	  	  ],
  	  	},
  	  	'testapp3' => {
  	  	}
  	  }	
      @chef_run.converge 'nginx_conf::default'
  	end
  	context 'block' do

  	end
  end
end