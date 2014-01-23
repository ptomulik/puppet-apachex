require 'spec_helper'

describe 'apachex::conf::httpd', :type => :define do
  context "on a FreeBSD" do
    let(:facts) do
      {
        :osfamily => 'FreeBSD',
        :operatingsystem => 'FreeBSD',
        :operatingsystemrelease => 9
      }
    end
    context "with all parameters default" do
      let(:title) { '/tmp/httpd.conf' }
      let(:params) { Hash.new }
      it { expect { subject }.to_not raise_error }
    end
  end
end
