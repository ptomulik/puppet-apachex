require 'spec_helper'
require 'facter/util/ptomulik/apachex'
describe Facter::Util::PTomulik::Apachex do

  describe 'default_exec_paths_hash' do
    it do
      described_class.default_exec_paths_hash.should be_instance_of Hash
    end
  end
  describe 'default_package_names_hash' do
    it do
      described_class.default_package_names_hash.should be_instance_of Hash
    end
  end
  describe 'default_exec_paths' do
    # Ensure that all OSes are supported
    [
      :archlinux,
      :debian,
      :freebsd,
      :redhat,
      'Archlinux',
      'Debian',
      'FreeBSD',
      'RedHat',
    ].each do |os|
      context "default_exec_paths(#{os.inspect})" do
        let(:os) { os }
        it do
          described_class.default_exec_paths(os).should be_instance_of String
        end
      end
    end
  end

  describe 'default_package_names' do
    # Ensure that all OSes are supported
    [
      :archlinux,
      :debian,
      :freebsd,
      :redhat,
      'Archlinux',
      'Debian',
      'FreeBSD',
      'RedHat',
    ].each do |os|
      context "default_exec_paths(#{os.inspect})" do
        let(:os) { os }
        it do
          described_class.default_package_names(os).should be_instance_of Array
        end
      end
    end
  end

  describe 'parse_version_output' do
    # Well or ill formed version in output
    [
      ['2.4.6', '2.4.6'],
      ['abc'  , nil],     # ill-formed version number (unacceptable)
      [''     , nil]      # empty - just for case
    ].each do |vers, expect|
      expect_str =  expect.nil? ? 'nil' : "#{expect.inspect}"
      output = "Server version: Apache/#{vers} (Debian)\n" + \
               "Server built:   Jul 23 2013 11:42:21\n"
      context "parse_version_output(#{output.inspect})'" do
        let(:output) { output }
        let(:expect) { expect }
        it do
          described_class.parse_version_output(output).should == expect
        end
      end
    end
    # Ill-formed output
    [
      "2.4.6\n",
      "\n"
    ].each do |output|
      context "parse_version_output(#{output.inspect})" do
        let(:output) { output }
        it do
          described_class.parse_version_output(output).should be_nil
        end
      end
    end
  end

  describe 'exec_path' do
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
      desc = 'when \'which()\' finds ' + findings.join(", and ")
      context desc do
        let(:items) { items }
        let(:expected) { expected }
        before :each do
          Facter::Util::Resolution.stubs(:which).returns(nil)
          items.each do |prog, path|
            Facter::Util::Resolution.stubs(:which).with(prog).returns(path)
          end
        end
        it do
          described_class.exec_path('Foo').should == expected
        end
      end
    end
    context 'when \'which()\' can\'t find apache\'s executable' do
      before :each do
        Facter::Util::Resolution.stubs(:which).returns(nil)
      end
      { 'Debian' => '/usr/sbin/apache2',
        'FreeBSD' => '/usr/local/sbin/httpd',
        'RedHat' => '/usr/sbin/httpd'
      }.each do |osfamily, path|
        { 'does not exist' => [false, false, nil],
          'is not executable' => [true, false, nil],
          'is not a file' => [false, true, nil],
          'is an executable file' => [true, true, path]
        }.each do |desc, args|
          context "and #{path.inspect} #{desc}" do
            before :each do
              File.stubs(:file?).with(path).returns(args[0])
              File.stubs(:executable?).with(path).returns(args[1])
            end
            context "exec_path(#{osfamily.inspect})" do
              let(:osfamily) { osfamily }
              let(:args) { args }
              it do
                described_class.exec_path(osfamily).should == args[2]
              end
            end
          end
        end
      end
    end
  end

  describe 'installed_version' do
    {
      'Debian'  => [ {:name => 'apache2', :ensure => '2.2.22-13'} ],
      'FreeBSD' => [ {:name => 'www/apache22', :ensure => '2.2.25'},
                     {:name => 'www/apache24', :ensure => '2.4.6'} ],
      'RedHat'  => [ {:name => 'httpd', :ensure => '2.2.15-26.el6.centos'} ],
    }.each do |osfamily, pkgs|
      context "installed_version(#{osfamily.inspect})" do
        let(:osfamily) { osfamily }
        pkgs.each do |pkg|
          context "with installed #{pkg[:name]} #{pkg[:ensure]}" do
            before :each do
              pkg.stubs(:is_a?).with(Puppet::Resource).returns(:true)
              ind = Puppet::Resource.indirection.class.any_instance
              ind.stubs(:find).returns({:ensure => :purged})
              ind.stubs(:find).with("package/#{pkg[:name]}").returns(pkg)
            end
            let(:pkg) { pkg }
            it do
              described_class.installed_version(osfamily).should == [pkg[:name],pkg[:ensure]]
            end
          end
        end
      end
    end
  end

  describe 'exec_version' do
    httpd = '/usr/sbin/apache2ctl'
    osfamily = 'SomeOS'
    context "when exec_path(#{osfamily.inspect}) is #{httpd.inspect}" do
      before :each do
        described_class.stubs(:exec_path).with(osfamily).once.returns(httpd)
      end
      [
        ['foo', nil],
        [ "Server version: Apache/2.4.6 (Debian)\nServer built:   Jul 23 2013 11:42:21\n", '2.4.6'],
      ].each do |output, version|
        context "and Facter::Util::Resolution.exec(\"#{httpd} -v\") returns #{output.inspect}" do
          let(:output) { output }
          let(:version) { version }
          let(:httpd) { httpd }
          let(:osfamily) { osfamily }
          before :each do
            Facter::Util::Resolution.stubs(:exec).with("#{httpd} -v").once.returns(output)
          end
          it "should call parse_version_output once with #{output.inspect}" do
            described_class.expects(:parse_version_output).once.with(output)
            described_class.exec_version(osfamily)
          end
          it do
            described_class.exec_version(osfamily).should == version
          end
        end
      end
    end
    context "when exec_path(#{osfamily.inspect}) is nil" do
      before :each do
        described_class.stubs(:exec_path).once.with(osfamily).returns(nil)
      end
      it do
        described_class.exec_version(osfamily).should be_nil
      end
    end
  end

  describe 'root_user' do
    {
      'Debian'  => 'root',
      'FreeBSD' => 'root'
    }.each do |osfamily,user|
      context "root_user(#{osfamily.inspect})" do
        let(:osfamily) { osfamily }
        let(:user) { user }
        it do
          described_class.root_user(osfamily).should == user
        end
      end
    end
    context "root_user('UnknownOS')" do
      it do
        expect { described_class.root_user('UnknownOS') }.
          to raise_error NotImplementedError, "UnknownOS is not supported"
      end
    end
  end

  describe 'root_group' do
    {
      'Debian'  => 'root',
      'FreeBSD' => 'wheel'
    }.each do |osfamily,group|
      context "root_group(#{osfamily.inspect})" do
        let(:osfamily) { osfamily }
        let(:group) { group }
        it do
          described_class.root_group(osfamily).should == group
        end
      end
    end
    context "root_group('UnknownOS')" do
      it do
        expect { described_class.root_group('UnknownOS') }.
          to raise_error NotImplementedError, "UnknownOS is not supported"
      end
    end
  end

  describe "pickup_version" do
    [
      [ 
        "apache2 2.2.22-13 2.4.6-2\n",
        [
          [ ['apache2', '2.2'], '2.2.22-13' ],
          [ ['apache2', '2.4'], '2.4.6-2' ],
          [ ['apache2', '2.6'], nil ],
          [ ['apache', '2.2'], nil ],
          [ ['httpd', '2.2'], nil ],
        ]
      ],
      [ 
        "apache2 2.2.22-13 2.4.6-2\napache2-mpm-prefork 2.2.22-13\n" + \
        "apache2-mpm-worker 2.2.22-13\n",
        [
          [ ['apache2', '2.2'], '2.2.22-13' ],
          [ ['apache2', '2.4'], '2.4.6-2' ],
          [ ['apache2-mpm-prefork', '2.2'], '2.2.22-13' ],
          [ ['apache2-mpm-prefork', '2.4'], nil ],
          [ ['apache2-mpm-worker', '2.2'], '2.2.22-13' ],
          [ ['apache2-mpm-worker', '2.4'], nil ],
        ]
      ],
      [ 
        "apache2 2.2.22-1 2.2.22-2 2.4.6-2\n",
        [
          [ ['apache2', '2.2'], '2.2.22-2' ],
        ]
      ],
      [ 
        "apache2 2.2.22-2 2.2.22-1\n",
        [
          [ ['apache2', '2.2'], '2.2.22-2' ],
        ]
      ],
      [ 
        "apache2 2.2.22_1 2.2.22_2 2.4.6_2\n",
        [
          [ ['apache2', '2.2'], '2.2.22_2' ],
        ]
      ],
      [ 
        "apache2 2.2.22-13 2.2.24-1 2.4.6-2\n",
        [
          [ ['apache2', '2.2'], '2.2.24-1' ],
        ]
      ],
      [ 
        "apache2 2.2.22-2 2.2.22-13 2.4.6-2\n",
        [
          [ ['apache2', '2.2'], '2.2.22-13' ],
        ]
      ],
      [ 
        "apache2 2.2.22_2 2.2.22_13 2.4.6-2\n",
        [
          [ ['apache2', '2.2'], '2.2.22_13' ],
        ]
      ],
    ].each do |versions,usecases|
      usecases.each do |args,expect|
        args << versions
        args_str = args.map{|x| x.inspect}.join(", ")
        context "apachex_pickup_version(#{args_str})" do
          let(:expect) { expect }
          let(:args) { args }
          it { described_class.pickup_version(*args).should == expect }
        end
      end
    end
  end
end
