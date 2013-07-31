require 'spec_helper'

describe 'apachex_exec fact:', :type => :fact do
  [
    [ # 0.
      { # this defines behavior of 'which()' method
        'apache2ctl'  => '/usr/sbin/apache2ctl',
        'apachectl'   => nil
      },
     '/usr/sbin/apache2ctl' # and this is the expected result
    ],
    [ # 1.
      { # this defines behavior of 'which()' method
        'apache2ctl'  => nil,
        'apachectl'   => '/usr/sbin/apachectl'
      },
     '/usr/sbin/apachectl' # and this is the expected result
    ],
    [ # 2.
      { # this defines behavior of 'which()' method
        'apache2ctl'  => '/usr/sbin/apache2ctl',
        'apachectl'   => '/usr/sbin/apachectl'
      },
     '/usr/sbin/apache2ctl' # and this is the expected result
    ],
  ].each do |items, expected|
    findings = []
    items.each do |prog, path|
      findings.push("'#{prog}' as '#{path}'") if not path.nil?
    end
    desc = 'if \'which()\' finds ' + findings.join(", and ")
    context desc do
      before :each do
        Facter::Util::Resolution.stubs(:which).returns(nil)
        items.each do |prog, path|
          Facter::Util::Resolution.stubs(:which).with(prog).returns(path)
        end
      end
      it "should return #{expected}" do
        Facter.value(:apachex_exec).should == expected
      end
    end
  end

  context 'if \'which()\' can\'t find apache\'s executable' do

    before :each do
      Facter::Util::Resolution.stubs(:which).returns(nil)
    end

    { 'Debian' => '/usr/sbin/apache2',
      'FreeBSD' => '/usr/local/sbin/httpd',
      'RedHat' => '/usr/sbin/httpd'
    }.each do |osfamily, path|
      context "and osfamily is #{osfamily}," do

        before :each do
          Facter.fact(:osfamily).stubs(:value).returns(osfamily)
        end

        { 'does not exist' => [false, false, nil],
          'is not executable' => [true, false, nil],
          'is not a file' => [false, true, nil],
          'is an executable file' => [true, true, path]
        }.each do |desc, args|
          context "and #{path} #{desc}" do
            before :each do
              File.stubs(:file?).with(path).returns(args[0])
              File.stubs(:executable?).with(path).returns(args[1])
            end
            should_val = args[2].nil? ? 'nil' : args[2]
            it "should be #{should_val}" do
              Facter.value(:apachex_exec).should == args[2]
            end
          end
        end
      end
    end
  end

end
