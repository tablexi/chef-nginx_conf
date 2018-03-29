lib = File.expand_path('../libraries', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'default'

describe 'nginx_conf::libraries::nginx_conf_options' do
  describe 'basic functionality' do
    it 'return empty string' do
      expect(nginx_conf_options({})).to eq ''
    end
    it 'check hash' do
      options = {
        'test' => {
          'key' => 'value'
        }
      }
      output = 'test key value;'
      expect(nginx_conf_options(options)).to eq output
    end
    it 'check hash' do
      options = {
        'test' => {
          'key' => 'value',
          'key1' => 'value1'
        }
      }
      output = ['test key value;', 'test key1 value1;'].join("\n")
      expect(nginx_conf_options(options)).to eq output
    end
    it 'check array' do
      options = {
        'test' => [
          '10',
          '20'
        ]
      }
      output = ['test 10;', 'test 20;'].join("\n")
      expect(nginx_conf_options(options)).to eq output
    end
    it 'check string' do
      options = {
        'test' => '1'
      }
      output = 'test 1;'
      expect(nginx_conf_options(options)).to eq output
    end
    it 'check block string' do
      expect(nginx_conf_options('block' => 'value')).to eq 'value;'
    end
    it 'check indent' do
      options = { 'the' => 'value' }
      indent = rand(10)
      output = '  ' * indent + 'the value;'
      expect(nginx_conf_options(options, indent)).to eq output
    end
  end
  describe 'locations' do
    it 'should parse them out' do
      options = {
        'locations' => {
          'test' => {
            'key' => 'value'
          }
        }
      }
      output = <<~CFG

        location test {
          key value;
        }
CFG
      expect(nginx_conf_options(options)).to eq output
    end
    it 'should parse nested as well' do
      options = {
        'locations' => {
          'test' => {
            'locations' => {
              'test again' => {
                'key' => 'value'
              }
            }
          }
        }
      }
      output = <<~CFG

        location test {

          location test again {
            key value;
          }

        }
CFG
      expect(nginx_conf_options(options)).to eq output
    end
  end

  describe 'if' do
    it 'should parse them out' do
      options = {
        'if' => {
          'test' => {
            'key' => 'value'
          }
        }
      }
      output = <<~CFG

        if (test) {
          key value;
        }
CFG
      expect(nginx_conf_options(options)).to eq output
    end
    it 'should parse nested as well' do
      options = {
        'if' => {
          'test' => {
            'if' => {
              'test again' => {
                'key' => 'value'
              }
            }
          }
        }
      }
      output = <<~CFG

        if (test) {

          if (test again) {
            key value;
          }

        }
CFG
      expect(nginx_conf_options(options)).to eq output
    end
  end

  describe 'upstream' do
    it 'should parse them out' do
      options = {
        'upstream' => {
          'test' => {
            'key' => 'value'
          }
        }
      }
      output = <<~CFG

        upstream test {
          key value;
        }
CFG
      expect(nginx_conf_options(options)).to eq output
    end
    it 'should parse nested as well' do
      options = {
        'upstream' => {
          'test' => {
            'upstream' => {
              'test again' => {
                'key' => 'value'
              }
            }
          }
        }
      }
      output = <<~CFG

        upstream test {

          upstream test again {
            key value;
          }

        }
CFG
      expect(nginx_conf_options(options)).to eq output
    end
  end

  describe 'limit_except' do
    it 'should parse them out' do
      options = {
        'limit_except' => {
          'test' => {
            'key' => 'value'
          }
        }
      }
      output = <<~CFG

        limit_except test {
          key value;
        }
CFG
      expect(nginx_conf_options(options)).to eq output
    end
    it 'should parse nested as well' do
      options = {
        'limit_except' => {
          'test' => {
            'limit_except' => {
              'test again' => {
                'key' => 'value'
              }
            }
          }
        }
      }
      output = <<~CFG

        limit_except test {

          limit_except test again {
            key value;
          }

        }
CFG
      expect(nginx_conf_options(options)).to eq output
    end
  end
end
