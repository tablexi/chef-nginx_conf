lib = File.expand_path('../../libraries', __FILE__)
$:.unshift(lib) unless $:.include?(lib)
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
	  	expect(output).to eq nginx_conf_options(options) 
	  end
	  it 'check hash' do
	  	options = {
	  	  'test' => {
	  	    'key' => 'value',
	  	    'key1' => 'value1'
	  	  }
	  	}
	  	output = ['test key value;', 'test key1 value1;'].join("\n")
	  	expect(output).to eq nginx_conf_options(options) 
	  end
	  it 'check array' do
	  	options = {
	  	  'test' => [
	  	  	'1',
	  	  	'2'
	  	  ]
	  	}
	  	output = ['test 1;', 'test 2;'].join("\n")
	  	expect(output).to eq nginx_conf_options(options) 
	  end
	  it 'check string' do
	  	options = {
	  	  'test' => '1'
	  	}
	  	output = 'test 1;'
	  	expect(output).to eq nginx_conf_options(options) 
	  end
	  it 'check block string' do
	  	expect(nginx_conf_options({'block' => 'value'})).to eq 'value;'
	  end
	  it 'check indent' do
	  	options = {'the' => 'value'}
	  	indent = rand(10)
	  	output = '  ' * indent + 'the value;'
	  	expect(nginx_conf_options(options, indent)).to eq output
	  end
	end
	describe 'locations' do
		it 'should parse them out' do
			options = {'locations' => {
					'test' => {
						'key' => 'value'
					}
				}
			}
			output = <<-CFG

location test {
  key value;
}
CFG
	  	expect(nginx_conf_options(options)).to eq output
		end
    it 'should parse nested as well' do
      options = {'locations' => {
          'test' => {
            'locations' => {
              'test again' => {
                'key' => 'value'
              }
            }
          }
        }
      }
      output = <<-CFG

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
      options = {'if' => {
          'test' => {
            'key' => 'value'
          }
        }
      }
      output = <<-CFG

if (test) {
  key value;
}
CFG
      expect(nginx_conf_options(options)).to eq output
    end
    it 'should parse nested as well' do
      options = {'if' => {
          'test' => {
            'if' => {
              'test again' => {
                'key' => 'value'
              }
            }
          }
        }
      }
      output = <<-CFG

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
      options = {'upstream' => {
          'test' => {
            'key' => 'value'
          }
        }
      }
      output = <<-CFG

upstream test {
  key value;
}
CFG
      expect(nginx_conf_options(options)).to eq output
    end
    it 'should parse nested as well' do
      options = {'upstream' => {
          'test' => {
            'upstream' => {
              'test again' => {
                'key' => 'value'
              }
            }
          }
        }
      }
      output = <<-CFG

upstream test {

  upstream test again {
    key value;
  }

}
CFG
      expect(nginx_conf_options(options)).to eq output
    end
  end
end
