module Puppet
newtype(:apachex_modules) do
  desc <<-EOT
    Apache modules for an apache instance.

    This resource maintains list of modules that shall be loaded at startup by
    an apache instance. This list shall not include MPM modules.

    The purpose of **apache_modules** is to either write the list of 
    [LoadModule](http://httpd.apache.org/docs/current/mod/mod_so.html#loadmodule)
    directives to **httpd.conf** or 

    *Example*:

        apachex_modules { foo:
          modules => {
            access_compat => 'mod_access_compat.so'
            authn_file => '/usr/lib/apache2/modules/mod_authn_file.so',
          }
        }
  EOT
  
  newparam(:name) do
    desc <<-EOT
      Identifies instances of the **apachex_modules** resource.
    EOT
    validate do |value|
      unless value.is_a? String
        raise ArgumentError,
          "name must be a String, not #{value.class}"
      end
    end
    defaultto do
      resource.value(:name)
    end
  end

  newparam(:modules) do
    desc <<-EOT
      Modules gathered by this resource. This is a hash in form:

          $modules = { xxx => '/path/to/mod_xxx.so', ...  }

      The keys and values in the hash correspond to `module` and `filename`
      parameter of the
      [LoadModule](http://httpd.apache.org/docs/current/mod/mod_so.html#loadmodule)
      directive respectively. Filenames may be given as either absolute paths
      or paths relative to `ServerRoot`. The above `key => value` pair shall
      generate the following **LoadModule** directive:

          LoadModule xxx_module /path/to/mod_xxx.so

      assuming that `id_suffix` is set to `_module` (which is the
      default).

      Keys must match `/^[a-zA-Z_]\w*$/` expression, that is they must be
      valid identifiers. Values must be Strings.
    EOT
    validate do |value|
      unless value.is_a? Hash
        raise ArgumentError,
          "modules must be an Hash, not #{value.class}"
      end
      if provider.respond_to?(:modules_validate)
        provider.modules_validate(value)
      else
        value.each do |key,val|
          unless /^[a-zA-Z_]\w*$/.match(key.to_s)
            raise ArgumentError,
              "Invalid module #{key.inspect}."
          end
          unless val.is_a?(String)
            raise ArgumentError,
              "Invalid filename #{val.inspect} for module #{key.inspect}."
          end
        end
      end
    end
  end

  newparam(:id_suffix) do
    desc <<-EOT
      Sets the suffix used for *module* parameter to the 
      [LoadModule](http://httpd.apache.org/docs/current/mod/mod_so.html#loadmodule)
      directive. The following code
      
          apachex_modules{xxx:
            modules => { 
              foo => '/path/to/mod_foo.so',
              bar => '/path/to/mod_bar.so'
            }
            id_suffix => '_sfx',
          }

      shall generate:

          LoadModule foo_sfx /path/to/mod_foo.so
          LoadModule bar_sfx /path/to/mod_bar.so

      The **id_suffix** parameter must be a String.
    EOT
    validate do |value|
      unless value.is_a? String
        raise ArgumentError,
          "id_suffix must be a String, not #{value.class}"
      end
    end
    defaultto '_module'
  end

  newparam(:id_map) do
    desc <<-EOT
      Maps **modules** to *module ids* (used by
      [LoadModule](http://httpd.apache.org/docs/current/mod/mod_so.html#loadmodule)).
      This provides a way to define custom *module ids* for modules, which for
      some reason can not use default *module ids* created by concatenating
      module name with **id_suffix**.

      This is a hash in form:

          $id_map = { 'xxx' => 'xxx_module', ... }

      which maps module names given as keys in **modules** to *module ids*
      used by **LoadModule** directives. For example, the following manifest

          apachex_modules{xxx:
            modules => {
              foo => '/path/to/mod_foo.so',
              bar => '/path/to/mod_bar.so'
            }
            id_map => {
              foo => custom_foo_id
            }
          }

      shall generate:

          LoadModule custom_foo_id /path/to/mod_foo.so
          LoadModule bar_module /path/to/mod_foo.so

      The **id_map** must be a Hash. Keys and values in **id_map** must match
      `/^[a-zA-Z_]\w*$/` regular expression, that is they must form valid
      identifiers.
    EOT
    validate do |value|
      unless value.is_a? Hash
        raise ArgumentError,
          "id_map must be an Hash, not #{value.class}"
      end
      if provider.respond_to?(:id_map_validate)
        provider.id_map_validate(value)
      else
        value.each do |key,val|
          unless /^[a-zA-Z_]\w*$/.match(key.to_s)
            raise ArgumentError,
              "Invalid module #{key.inspect}."
          end
          unless /^[a-zA-Z_]\w*$/.match(val.to_s)
            raise ArgumentError,
              "Invalid id #{val.inspect} for module #{key.inspect}."
          end
        end
      end
    end
    defaultto Hash.new
  end
end
end
