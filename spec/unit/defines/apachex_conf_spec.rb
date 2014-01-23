require 'spec_helper'

describe 'apachex::conf', :type => :define do
  context "without any parameters" do
    let(:title)   { '/tmp/foo.conf' }
    let(:params)  { Hash.new }
    it { should contain_file(title).with({}) }
  end

  context "with all parameters" do
    let(:all_params)  do
      {
        :path                     => '/tmp/foo.conf',
        :ensure                   => 'file',
        :backup                   => '.bak',
        :checksum                 => 'md5',
        :content                  => 'foo',
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
        :source                   => '/tmp/bar.conf',
        :source_permissions       => 'use',
        :sourceselect             => 'first',
        :target                   => '/tmp/geez.conf',
        :template                 => 'apachex/spec/static.conf.erb',
        :subst                    => { 'foo' => 'Foo' }
      }
    end
    [
      [[:content,:source,:target,:template],{}],
      [[:source,:target,:template],{}],
      [[:content,:target,:template],{}],
      [[:content,:source,:template],{}],
      [[:content,:source,:target],{}],
    ].each do |remove,overwrite|
      context "but #{remove.join(", ")}" do
        let(:title)   { 'foo.conf file' }
        let(:params)  do
          all_params.reject{|k,v| remove.include? k}.merge(overwrite)
        end
        let(:conf_params) do
          [:subst,:template]
        end
        let(:file_params) do
          if params.include?(:template)
            params.reject{|k,v| conf_params.include? k}.merge({:content => "# static content\n"})
          else
            params.reject{|k,v| conf_params.include? k}
          end
        end
        it { should contain_file(title).with(file_params) }
      end
    end
  end
  context "with ensure => xyz" do
    msg = "\"xyz\" does not match"
    let(:title)  { '/tmp/foo.conf' }
    let(:params) { { :ensure => 'xyz' } }
    let(:msg)    { msg }
    it "should fail with message matching /#{msg}/" do
      expect { subject }.to raise_error(Puppet::Error,/#{msg}/)
    end
  end
  context "with mututally exclusive parameters" do
    let(:all_params)  do
      {
        :content                  => 'foo',
        :source                   => '/tmp/bar.conf',
        :target                   => '/tmp/geez.conf',
        :template                 => 'apachex/spec/static.conf.erb',
      }
    end
    [
      [:source,   :content],
      [:source,   :target],
      [:source,   :template],
      [:content,  :target],
      [:content,  :template],
      [:target,   :template],
    ].each do |parameters|
      context "with #{parameters[0]} and #{parameters[1]}" do
        msg =  Regexp.escape("#{parameters[0]} and #{parameters[1]} are mutually exclusive")
        let(:title)   { '/tmp/foo.conf' }
        let(:params)  { all_params.select{|k,v| parameters.include? k} }
        let(:msg)     { msg }
        it "should fail with message matching: /#{msg}/" do
          expect { subject }.to raise_error(Puppet::Error,/#{msg}/)
        end
      end
    end
  end
end
