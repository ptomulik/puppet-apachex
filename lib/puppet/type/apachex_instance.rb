require 'facter'

module Puppet
newtype(:apachex_instance) do
  desc <<-EOT
    Instance of apache server, supports running multiple instances of apache.

    Some platforms allow running multiple instances of apache server with
    different configurations and as different users. This pattern is used by
    to setup hosting environments with decent privilege separation
    (for example, multiple instances of http server behind a reverse proxy).
    
    The **apachex_instance** resource represents single instance of a running
    apache server in puppet manifest. It's main puprose is to autorequire other
    "per instance" resources that are necessary to setup the instance properly.
    It also maintains resources that can't be handled by other resource types.
    
    As an example of system resources maintained by **apachex_instance** one can
    take the `freebsd` provider which maintains a configuration file named
    `/etc/rc.conf.d/${apache_name}_instances.conf`. The file defines a list of
    apache instances that should be started at boot time. See 
    [wiki article](http://wiki.apache.org/httpd/RunningMultipleApacheInstances)
    for more details.
    
    Note that **apachex_instance** does not start any instances by it's own and
    doesn't create any additional resources. It just sets soft dependence to
    other resources, which should be defined in manifest file for each
    apache instance.
  EOT

  newparam(:name) do
    desc <<-EOT
      Instance name. Identifies instances of the **apachex_instance** resource.

      The **name** must be a string matching `/^[a-zA-Z_]\w*$/` regular
      expression, that is it must be a valid identifier such as `foo_bar24`.
    EOT
    newvalues /^[a-zA-Z_]\w*$/
    isnamevar
  end

  newparam(:modules) do
    desc <<-EOT
      Name of **apachex_modules** for this apache instance. It defines the
      module list to be loaded at startup by this apache instance. 

      The `modules` must be a string.
    EOT
    validate do |value|
      unless value.is_a? String
        raise ArgumentError,
          "modules must be a String, not #{value.class}"
      end
    end
    defaultto do
      resource.value(:name)
    end
  end

##  newparam(:apache_name) do
##    desc <<-EOT
##      Name of the apache installation. This would be `"apache"` on
##      slackware, `"apache2"` on Debian, `"apache22"` on FreeBSD, etc..
##      
##      This string may be used by `apachex_instance` to generate filenames for
##      some configuration files or to generate variable names in these configs.
##      In most cases you don\'t need to change defaults here.
##    
##      The `apache_name` must be a string matching regular expression
##      `/^[a-z][a-z0-9_]+$/`, that is, it must be a lower-case identifier.
##    
##      Default: root
##    EOT
##    newvalues(/^[a-z][a-z0-9_]+$/)
##  end
##  newparam(:apache_version) do
##    desc <<-EOT
##      Version of the apache executable which the instance will run.
##      
##    
##      The `apache_version` must be a string matching regular expression
##      `/^[0-9]+\.[0-9]+(?:\.[0-9]+(:?[_\.-][\w,]+)?)?$/`. Example values
##      matching the expression are `2.2`, `2.2.5`, `2.2.24-5,423`.
##    EOT
##    newvalues(/^[0-9]+\.[0-9]+(?:\.[0-9]+(:?[_\.-][\w,]+)?)?$/)
##  end
##  newparam(:user) do
##    desc <<-EOT
##      User that the apache service will run as.
##    
##      The value of `user` parameter may be used to set appropriate ownership
##      for some files, generate path names for configuration files etc..
##    EOT
##    validate do |value|
##      unless value.is_a? String
##        raise ArgumentError,
##          "user must be a String, not #{value.class}"
##      end
##      super(value)
##    end
##    defaultto do
##      Facter.value(:apachex_root_user)
##    end
##  end
##  newparam(:group) do
##    desc <<-EOT
##      Group name of the `user`\'s main group. 
##      
##      Default: none (default value is chosen by provider).
##    EOT
##    validate do |value|
##      unless value.is_a? String
##        raise ArgumentError,
##          "group must be a String, not #{value.class}"
##      end
##      super(value)
##    end
##    defaultto do 
##      Facter.value(:apachex_root_group)
##    end
##  end
  newparam(:instance_options) do
    desc <<-EOT
      Additional provider-specific options.
    
      The **instance_options** must be a Hash.
    
      Default: {}
    EOT
    validate do |value|
      unless value.is_a? Hash
        raise ArgumentError,
          "instance_options must be an Hash, not #{value.class}"
      end
      if provider.respond_to?(:instance_options_validate)
        provider.instance_options_validate(value)
      else
        super(value)
      end
    end
    defaultto Hash.new
  end

  autorequire(:apachex_modules) do
    resource.value(:modules)
  end
end
end
