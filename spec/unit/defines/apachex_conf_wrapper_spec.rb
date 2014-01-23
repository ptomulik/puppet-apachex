require 'spec_helper'

describe 'apachex::conf_wrapper', :type => :define do
  context "without any parameters" do
    let(:title)   { '/tmp/foo.conf' }
    let(:params)  { Hash.new }
    it { should contain_apachex__conf(title).with({}) }
  end

  context "with all parameters" do
    let(:all_free_params) do
      {
        :path         => '/tmp/foo.conf',
        :ensure       => 'file',
        :content      => 'foo',
        :source       => '/tmp/bar.conf',
        :target       => '/tmp/geez.conf',
        :template     => 'apachex/spec/static.conf.erb',
        :subst        => { 'foo' => 'Foo' }
      }
    end
    let(:all_file_params) do
      {
        :backup                   => '.bak',
        :checksum                 => 'md5',
        :force                    => true,
        :group                    => 'wheel',
        :ignore                   => 'xyz/*',
        :links                    => 'manage',
        :mode                     => 'a=r,ug+w',
        :owner                    => 'root',
        :provider                 => 'posix',
        :purge                    => false,
        :recurse                  => true,
        :recurselimit             => 4,
        :replace                  => true,
        :selinux_ignore_defaults  => false,
        :selrange                 => 's0',
        :selrole                  => 'role_r',
        :seltype                  => 'tmp_t',
        :seluser                  => 'user_u',
        :show_diff                => false,
        :source_permissions       => 'use',
        :sourceselect             => 'first',
      }
    end
    let(:all_params)  do
      all_free_params.merge({:file_params => Hash[all_file_params.map{|k,v| [k.to_s,v]}]})
    end
    [
      [:content,:source,:target,:template],
      [:source,:target,:template],
      [:content,:target,:template],
      [:content,:source,:template],
      [:content,:source,:target],
    ].each do |remove|
      context "but #{remove.join(", ")}" do
        let(:title)   { 'foo.conf file' }
        let(:params)  { all_params.reject{|k,v| remove.include? k} }
        let(:conf_params) { all_file_params.merge(all_free_params).reject{|k,v| remove.include? k} }
        it { should contain_apachex__conf(title).with(conf_params) }
      end
    end
  end
  context "with file_params => xyz" do
    msg = "\"xyz\" is not a Hash"
    let(:title)  { '/tmp/foo.conf' }
    let(:params) { { :file_params => 'xyz' } }
    let(:msg)    { msg }
    it "should fail with message matching /#{msg}/" do
      expect { subject }.to raise_error(Puppet::Error,/#{msg}/)
    end
  end
end
