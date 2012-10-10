# test/kitchen/cookbooks/nginx_conf_test/files/default/tests/minitest/default.rb

describe_recipe 'nginx_conf_test::default' do

  include MiniTest::Chef::Assertions
  include MiniTest::Chef::Context
  include MiniTest::Chef::Resources

  describe "testing nginx_conf default cookbook" do
    before do
      @base_path = File.join(node['nginx']['dir'], 'sites-available')
      @base_sym = File.join(node['nginx']['dir'], 'sites-enabled')
    end

    describe "test1.mywebsite.com" do
      before do
        @path = File.join(@base_path, 'test1.mywebsite.com')
        @sym = File.join(@base_sym, 'test1.mywebsite.com')
      end

      it "created the test1 config file" do
        file(@path).must_exist
      end

      it "symlinked sites-avilable/test1.mywebsite.com to sites-enabled/test1.mywebsite.com" do
        link(@sym).must_exist.with(:link_type, :symbolic).and(:to, @path)
      end

      it "should include the default location decleration on test1" do
        file(@path).must_include 'location /'
      end

    end

    describe "test2.mywebsite.com" do
      before do
        @path = File.join(@base_path, 'test2.mywebsite.com')
        @sym = File.join(@base_sym, 'test2.mywebsite.com')
      end

      it "created the test2.mywebsite.com config file with symlink" do
        file(@path).must_exist
        link(@sym).must_exist.with(:link_type, :symbolic).and(:to, @path)
      end

      it "should not include the default location decleration on test2" do
        file(@path).wont_include 'location /'
      end

    end

    describe "test3.mywebsite.com" do
      before do
        @path = File.join(@base_path, 'test3.mywebsite.com')
        @sym = File.join(@base_sym, 'test3.mywebsite.com')
      end

      it "removes symlink for test3.mywebsite.com, but leaves the file" do
        file(@path).must_exist
        link(@sym).wont_exist
      end

    end

    describe "test4.mywebsite.com" do
      before do
        @path = File.join(@base_path, 'test4.mywebsite.com')
        @sym = File.join(@base_sym, 'test4.mywebsite.com')
      end

      it "removes file and symlink for test4.website.com" do
        file(@path).wont_exist
        link(@sym).wont_exist
      end

    end
    
  end

end
