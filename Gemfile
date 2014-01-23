source 'https://rubygems.org'

group :development, :test do                                                    
  gem 'rake' 
  gem 'rspec-puppet'
  gem 'puppetlabs_spec_helper',  :require => false                              
#  gem 'serverspec',              :require => false                              
#  gem 'rspec-system',            :require => false                              
  gem 'rspec-system-puppet'
  gem 'rspec-system-serverspec', :require => false                              
  if RUBY_VERSION >= '1.9'
    gem 'coveralls', :require => false
    gem 'yard'
    gem 'redcarpet'
  end
  gem 'puppet-lint'
end                                                                             

if puppetversion = ENV['PUPPET_GEM_VERSION']                                    
  gem 'puppet', puppetversion, :require => false                                
else                                                                            
  gem 'puppet', :require => false                                               
end                                                                             

# vim:ft=ruby                                                                   
