require 'spec_helper'

describe 'the apachex_pickup_version function' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it 'should_exist' do
    Puppet::Parser::Functions.function('apachex_pickup_version').should \
                           == 'function_apachex_pickup_version'
  end

  it 'should raise a ParseError if there is less than 3 arguments' do
    lambda { scope.function_apachex_pickup_version([]) }.should( raise_error(Puppet::ParseError))
    lambda { scope.function_apachex_pickup_version(['0']) }.should( raise_error(Puppet::ParseError))
    lambda { scope.function_apachex_pickup_version(['0','1']) }.should( raise_error(Puppet::ParseError))
  end
  
  it 'should raise a ParseError if argument 1 or 2 is not a string' do
    lambda { scope.function_apachex_pickup_version([nil,'','']) }.should( raise_error(Puppet::ParseError))
    lambda { scope.function_apachex_pickup_version(['',nil,'']) }.should( raise_error(Puppet::ParseError))
  end

  [
    [ 
      "apache2 2.2.22-13 2.4.6-2\n",
      [ 'apache2', '2.2', '2.2.22-13' ],
      [ 'apache2', '2.4', '2.4.6-2' ],
      [ 'apache2', '2.6', nil ],
      [ 'apache', '2.2', nil ],
      [ 'httpd', '2.2', nil ],
    ],
    [ 
      "apache2 2.2.22-13 2.4.6-2\napache2-mpm-prefork 2.2.22-13\n" + \
      "apache2-mpm-worker 2.2.22-13\n",
      [ 'apache2', '2.2', '2.2.22-13' ],
      [ 'apache2', '2.4', '2.4.6-2' ],
      [ 'apache2-mpm-prefork', '2.2', '2.2.22-13' ],
      [ 'apache2-mpm-prefork', '2.4', nil ],
      [ 'apache2-mpm-worker', '2.2', '2.2.22-13' ],
      [ 'apache2-mpm-worker', '2.4', nil ],
    ],
    [ 
      "apache2 2.2.22-1 2.2.22-2 2.4.6-2\n",
      [ 'apache2', '2.2', '2.2.22-2' ],
    ],
    [ 
      "apache2 2.2.22-2 2.2.22-1\n",
      [ 'apache2', '2.2', '2.2.22-2' ],
    ],
    [ 
      "apache2 2.2.22_1 2.2.22_2 2.4.6_2\n",
      [ 'apache2', '2.2', '2.2.22_2' ],
    ],
    [ 
      "apache2 2.2.22-13 2.2.24-1 2.4.6-2\n",
      [ 'apache2', '2.2', '2.2.24-1' ],
    ],
    [ 
      "apache2 2.2.22-2 2.2.22-13 2.4.6-2\n",
      [ 'apache2', '2.2', '2.2.22-13' ],
    ],
    [ 
      "apache2 2.2.22_2 2.2.22_13 2.4.6-2\n",
      [ 'apache2', '2.2', '2.2.22_13' ],
    ],
  ].each do |items|
    repo_versions_string = items[0]
    repo_versions_desc = repo_versions_string.chomp.split("\n").join(", and ")
    context "with available packages versions #{repo_versions_desc}" do
      items[1..(items.size-1)].each do |args|
        package = args[0]
        version = args[1]
        expect = args[2]
        expect_str = expect.nil? ? 'nil' : "'#{expect}'"
        context "and arguments package='#{package}', version='#{version}'" do
          it "should return #{expect_str}" do
            result = scope.function_apachex_pickup_version([package,version,repo_versions_string])
            result.should == expect
          end
        end
      end
    end
  end
end
