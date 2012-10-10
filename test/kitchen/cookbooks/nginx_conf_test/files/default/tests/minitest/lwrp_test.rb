# test/kitchen/cookbooks/nginx_conf_test/files/default/tests/minitest/lwrp.rb

describe_recipe 'nginx_conf_test::lwrp' do

  include MiniTest::Chef::Assertions
  include MiniTest::Chef::Context
  include MiniTest::Chef::Resources

  describe "testing nginx_conf_file LWRP" do
    before do
      @base_path = File.join(node['nginx']['dir'], 'sites-available')
      @base_sym = File.join(node['nginx']['dir'], 'sites-enabled')
    end

    it "nginx should be running whether nginx_conf succeded or not." do
      service('nginx').must_be_running
    end

    describe "test5.mywebsite.com" do
      before do
        @path = File.join(@base_path, 'test5.mywebsite.com')
        @sym = File.join(@base_sym, 'test5.mywebsite.com')
      end

      it "created the test5 config file" do
        file(@path).must_exist
      end

      it "symlinked sites-avilable/test5.mywebsite.com to sites-enabled/test5.mywebsite.com" do
        link(@sym).must_exist.with(:link_type, :symbolic).and(:to, @path)
      end

      it "should include the default location decleration on test5" do
        file(@path).must_include('location /')
      end

    end

    describe "test6.mywebsite.com" do
      before do
        @path = File.join(@base_path, 'test6.mywebsite.com')
        @sym = File.join(@base_sym, 'test6.mywebsite.com')
      end

      it "created the test6.mywebsite.com config file with symlink" do
        file(@path).must_exist
        link(@sym).must_exist.with(:link_type, :symbolic).and(:to, @path)
      end

      it "should not include the default location decleration on test6" do
        file(@path).wont_include 'location /'
      end

    end

    describe "test7.mywebsite.com" do
      before do
        @path = File.join(@base_path, 'test7.mywebsite.com')
        @sym = File.join(@base_sym, 'test7.mywebsite.com')
      end

      it "removes symlink for test7.mywebsite.com, but leaves the file" do
        file(@path).must_exist
        link(@sym).wont_exist
      end

    end

    describe "test8.mywebsite.com" do
      before do
        @path = File.join(@base_path, 'test8.mywebsite.com')
        @sym = File.join(@base_sym, 'test8.mywebsite.com')
      end

      it "removes file and symlink for test8.website.com" do
        file(@path).wont_exist
        link(@sym).wont_exist
      end

    end
    
  end

end
