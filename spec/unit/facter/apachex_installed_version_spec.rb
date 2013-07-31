require 'spec_helper'
require 'puppet/resource'

describe 'apachex_installed_version fact:', :type => :fact do

  { 
    'Debian'  => [ {:name => 'apache2', :ensure => '2.2.22-13'} ],
    'FreeBSD' => [ {:name => 'www/apache22', :ensure => '2.2.25'},
                   {:name => 'www/apache24', :ensure => '2.4.6'} ],
    'RedHat'  => [ {:name => 'httpd', :ensure => '2.2.22-13'} ],
  }.each do |osfamily, pkgs|
    context "on #{osfamily}" do
      before :each do
        Facter.fact(:osfamily).stubs(:value).returns(osfamily)
      end
      pkgs.each do |pkg|
        context "with installed '#{pkg[:name]} #{pkg[:ensure]}'" do
          before :each do
            pkg.stubs(:is_a?).with(Puppet::Resource).returns(:true)
            ind = Puppet::Resource.indirection
            ind.stubs(:find).returns({:ensure => :purged})
            ind.stubs(:find).with("package/#{pkg[:name]}").returns(pkg)
          end
          it  "should return '#{pkg[:name]} #{pkg[:ensure]}'" do
            fact = Facter.value(:apachex_installed_version)
            fact.should == "#{pkg[:name]} #{pkg[:ensure]}"
          end
        end
      end
    end
  end

end
