require_relative 'spec_helper'

describe 'nginx_conf_file' do
  let(:chef_run) { ChefSpec::ServerRunner.new(step_into: 'nginx_conf_file') }

  context 'create action' do
    before do
      chef_run.converge 'fake::create'
    end

    it 'to create a template file' do
      expect(chef_run).to create_template("#{chef_run.node[:nginx][:dir]}/sites-available/testapp1")
    end

    it 'template to notify delayed execute test' do
      expect(chef_run.template("#{chef_run.node[:nginx][:dir]}/sites-available/testapp1")).to notify('execute[test-nginx-conf-testapp1-create]').to(:run).delayed
    end

    it 'to link sites-available to sites-enabled' do
      expect(chef_run).to create_link("#{chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")
      expect(chef_run.link("#{chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")).to link_to("#{chef_run.node[:nginx][:dir]}/sites-available/testapp1")
    end

    it 'link to notify delayed execute test' do
      expect(chef_run.link("#{chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")).to notify('execute[test-nginx-conf-testapp1-create]').to(:run).delayed
    end

    it 'to restart nginx' do
      expect(chef_run.execute("#{chef_run.node[:nginx][:binary]} -t")).to notify('service[nginx]').to(:restart).delayed
    end

    describe 'ssl' do
      it 'to create ssl directory' do
        expect(chef_run).to create_directory("#{chef_run.node[:nginx][:dir]}/ssl")
      end
      it 'to create testapp3 cert files' do
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/ssl/testapp3.public.crt").with_content('crt')
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/ssl/testapp3.private.key").with_content('key')
      end
      it 'to normal ssl info in testapp3 conf' do
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/sites-available/testapp3").with_content('ssl on;')
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/sites-available/testapp3").with_content('ssl_certificate /etc/nginx/ssl/testapp3.public.crt;')
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/sites-available/testapp3").with_content('ssl_certificate_key /etc/nginx/ssl/testapp3.private.key;')
      end
      it 'to create testapp4 cert file with normal name' do
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/ssl/test-ssl4.public.crt").with_content('testapp4_crt')
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/ssl/test-ssl4.private.key").with_content('testapp4_key')
      end
      it 'to normal ssl info in testapp4 conf' do
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/sites-available/testapp4").with_content('ssl on;')
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/sites-available/testapp4").with_content('ssl_certificate /etc/nginx/ssl/test-ssl4.public.crt;')
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/sites-available/testapp4").with_content('ssl_certificate_key /etc/nginx/ssl/test-ssl4.private.key;')
      end
      it 'to create testapp5 cert file with normal name' do
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/ssl/test-ssl5.public.crt").with_content('testapp5_crt')
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/ssl/test-ssl5.private.key").with_content('testapp5_key')
      end
      it 'to normal ssl info in testapp5 conf' do
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/sites-available/testapp5").with_content('ssl on;')
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/sites-available/testapp5").with_content('ssl_certificate /etc/nginx/ssl/test-ssl5.public.crt;')
        expect(chef_run).to render_file("#{chef_run.node[:nginx][:dir]}/sites-available/testapp5").with_content('ssl_certificate /etc/nginx/ssl/test-ssl5.public.crt;')
      end
      it 'should notify nginx-test' do
        expect(chef_run.template('testapp3_public_crt')).to notify('execute[test-nginx-conf-testapp3-create]').to(:run).delayed
        expect(chef_run.template('testapp3_private_key')).to notify('execute[test-nginx-conf-testapp3-create]').to(:run).delayed
        expect(chef_run.template('test-ssl4_public_crt')).to notify('execute[test-nginx-conf-testapp4-create]').to(:run).delayed
        expect(chef_run.template('test-ssl4_private_key')).to notify('execute[test-nginx-conf-testapp4-create]').to(:run).delayed
        expect(chef_run.template('test-ssl5_public_crt')).to notify('execute[test-nginx-conf-testapp5-create]').to(:run).delayed
        expect(chef_run.template('test-ssl5_private_key')).to notify('execute[test-nginx-conf-testapp5-create]').to(:run).delayed
      end
    end
  end

  context 'delete action' do
    context 'basic' do
      before do
        chef_run.converge 'fake::delete'
      end

      it 'to remove link from sites-available to sites-enabled' do
        expect(chef_run).to delete_link("#{chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")
      end

      it 'to delete file from sites-available' do
        expect(chef_run).to delete_file("#{chef_run.node[:nginx][:dir]}/sites-available/testapp1")
      end

      it 'to restart nginx' do
        expect(chef_run.file("#{chef_run.node[:nginx][:dir]}/sites-available/testapp1")).to notify('service[nginx]').to(:restart).delayed
      end
    end

    context 'ssl' do
      it 'to delete ssl file if present' do
        chef_run.converge 'fake::delete'
        expect(chef_run).to delete_file("#{chef_run.node[:nginx][:dir]}/ssl/testapp1.public.crt")
        expect(chef_run).to delete_file("#{chef_run.node[:nginx][:dir]}/ssl/testapp1.private.key")
      end

      it 'to not delete if attribute normal to false' do
        chef_run.node.normal[:nginx_conf][:delete][:ssl] = false
        chef_run.converge 'fake::delete'
        expect(chef_run).not_to delete_file("#{chef_run.node[:nginx][:dir]}/ssl/testapp1.public.crt")
        expect(chef_run).not_to delete_file("#{chef_run.node[:nginx][:dir]}/ssl/testapp1.private.key")
      end

      it 'to not delete if provider resource attribute is normal to false' do
        chef_run.node.normal[:nginx_conf][:delete][:ssl] = true
        chef_run.converge 'fake::delete'
        expect(chef_run).to delete_file("#{chef_run.node[:nginx][:dir]}/ssl/testapp1.public.crt")
        expect(chef_run).to delete_file("#{chef_run.node[:nginx][:dir]}/ssl/testapp1.private.key")
        expect(chef_run).not_to delete_file("#{chef_run.node[:nginx][:dir]}/ssl/testapp2.public.crt")
        expect(chef_run).not_to delete_file("#{chef_run.node[:nginx][:dir]}/ssl/testapp2.private.key")
      end
    end
  end

  context 'enable action' do
    before do
      chef_run.converge 'fake::enable'
    end

    it 'to link sites-available to sites-enabled' do
      expect(chef_run).to create_link("#{chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")
      expect(chef_run.link("#{chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")).to link_to("#{chef_run.node[:nginx][:dir]}/sites-available/testapp1")
    end

    it 'link to notify delayed execute test' do
      expect(chef_run.link("#{chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")).to notify('execute[test-nginx-conf-testapp1-enable]').to(:run).delayed
    end

    it 'to restart nginx' do
      expect(chef_run.execute("#{chef_run.node[:nginx][:binary]} -t")).to notify('service[nginx]').to(:restart).delayed
    end
  end

  context 'disable action' do
    before do
      chef_run.converge 'fake::disable'
    end

    it 'to unlink sites-available from sites-enabled' do
      expect(chef_run).to delete_link("#{chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")
    end

    it 'to restart nginx' do
      expect(chef_run.link("#{chef_run.node[:nginx][:dir]}/sites-enabled/testapp1")).to notify('service[nginx]').to(:restart).delayed
    end
  end
end
