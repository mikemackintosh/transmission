require 'rubygems' if RUBY_VERSION < '1.9'

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/reloader'
require 'sinatra/session'
require 'logger'
require 'net/ssh'
require 'rack-flash'
require 'sshkey'

module Transmission

  class App < Sinatra::Base

    register Sinatra::ConfigFile
    register Sinatra::Session

	  configure do
    	set :app_path, File.dirname(__FILE__)
    end

    def create_ssh_key( user, pass, email )

      if File.file?('#{settings.app_path}/keys/#{user}_rsa')
        false
      else

        k = SSHKey.generate(:type => "RSA", :bits => 4093, :comment => "#{user},#{email}", :passphrase => "#{pass}")

        # Write Private Key
        File.open("#{settings.app_path}/keys/#{user}_rsa", 'w') { |file| 
          file.write(k.encrypted_private_key) 
        }        

        # Write Public Key
        File.open("#{settings.app_path}/keys/#{user}_rsa.pub", 'w') { |file| 
          file.write(k.public_key) 
        }

        true

      end

    end

    def check_ssh_key( user, pass )
      
      file = "#{settings.app_path}/keys/#{user}_rsa"
      if File.file?(file)
        begin
          private_key = OpenSSL::PKey::RSA.new(File.read(file), pass)
          
          k = SSHKey.new(private_key)
          
          public_key = File.read("#{file}.pub")
          
          if k.public_key == public_key 
            puts "Authenticated Successfully"
            true
          else
            puts "Authentication Failed"
            true
          end
        rescue
          puts "Invalid passphrase"
        end
      else
        puts "Authentication Fail"
        false
      end
    end
    
    enable :sessions
    enable :method_override
    enable :logging

    use Rack::Flash

    require_relative 'routes/init'

  end
end
