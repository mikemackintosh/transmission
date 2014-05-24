require 'rubygems' if RUBY_VERSION < '1.9'

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/reloader'
require 'sinatra/session'
require 'logger'
require 'net/ssh'
require 'rack-flash'
require 'RubyExpect'

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
        %x[ssh-keygen -t rsa -b 4093 -q -C "#{user},#{email}" -f #{settings.app_path}/keys/#{user}_rsa -N'#{pass}' ]
        result = $?.to_i
        if result == 0
          true
        else
          false
        end

      end
    end

    def check_ssh_key( user, pass )
      # %x[ssh-keygen -y -f #{settings.app_path}/keys/#{user}_rsa -p'#{pass}' ]
      exp = RubyExpect::Expect.spawn('ssh-keygen -y -f #{settings.app_path}/keys/#{user}_rsa', :debug => true)
      exp.procedure do
        each do
          expect `passphrase: ` do
            send pass
          end
        end
      end
    end
    
    enable :sessions
    enable :method_override
    enable :logging

    use Rack::Flash

    require_relative 'routes/init'

  end
end
