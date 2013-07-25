require_relative 'spec_helper'

describe 'nginx_conf_file' do
  before do
    @chef_run = chef_run()
  end
  context 'create action' do
    before do
      @chef_run.converge 'fake::create'
    end

    it 'should create a template file' do
      expect(@chef_run).to create_file "#{@chef_run.node[:nginx][:dir]}/sites-available/testapp1"
    end

    it 'template should notify delayed execute test' do
      pending 'notify delayed resource error'
      expect(@chef_run.template("#{@chef_run.node[:nginx][:dir]}/sites-available/testapp1")).to notify 'execute[test-nginx-conf-testapp1-create]', :run
    end

    it 'should link sites-available to sites-enabled' do
      expect(@chef_run).to create_link "#{@chef_run.node[:nginx][:dir]}/sites-enabled/testapp1"
    	expect(@chef_run.link("#{@chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")).to link_to "#{@chef_run.node[:nginx][:dir]}/sites-available/testapp1"
    end

    it 'link should notify delayed execute test' do
      pending 'notify delayed resource error'
      expect(@chef_run.link("#{@chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")).to notify 'execute[test-nginx-conf-testapp1-create]', :run
    end

    it 'should execute nginx test' do
    	expect(@chef_run).to execute_command "#{@chef_run.node[:nginx][:binary]} -t"
    end

    it 'should restart nginx' do
      pending 'notify delayed resource error'
    	expect(@chef_run.execute("#{@chef_run.node[:nginx][:binary]} -t")).to notify 'service[nginx]', :restart
    end
  end

  context 'delete action' do
    before do
      @chef_run.converge 'fake::delete'
    end

    it 'should remove link from sites-available to sites-enabled' do
      expect(@chef_run).to delete_link "#{@chef_run.node[:nginx][:dir]}/sites-enabled/testapp1"
    end

    it 'should delete file from sites-available' do
      expect(@chef_run).to delete_file "#{@chef_run.node[:nginx][:dir]}/sites-available/testapp1"
    end

    it 'should restart nginx' do
      pending 'notify delayed resource error'
      expect(@chef_run.file("#{@chef_run.node[:nginx][:dir]}/sites-available/testapp1")).to notify('service[nginx]', :restart)
    end
  end

  context 'enable action' do
    before do
      @chef_run.converge 'fake::enable'
    end

    it 'should link sites-available to sites-enabled' do
      expect(@chef_run).to create_link "#{@chef_run.node[:nginx][:dir]}/sites-enabled/testapp1"
      expect(@chef_run.link("#{@chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")).to link_to "#{@chef_run.node[:nginx][:dir]}/sites-available/testapp1"
    end

    it 'should execute nginx test' do
      expect(@chef_run).to execute_command "#{@chef_run.node[:nginx][:binary]} -t"
    end

    it 'should restart nginx' do
      pending 'notify delayed resource error'
      expect(@chef_run.execute("#{node[:nginx][:binary]} -t")).to notify('service[nginx]', :restart)
    end
  end

  context 'disable action' do
    before do
      @chef_run.converge 'fake::disable'
    end

    it 'should unlink sites-available from sites-enabled' do
      expect(@chef_run).to delete_link "#{@chef_run.node[:nginx][:dir]}/sites-enabled/testapp1"
    end

    it 'should restart nginx' do
      pending 'notify delayed resource error'
      expect(@chef_run.link("#{@chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")).to notify('service[nginx]', :restart)
    end
  end

end