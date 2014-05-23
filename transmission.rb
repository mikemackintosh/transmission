require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/reloader'
require 'sinatra/session'
require 'logger'
require 'rack-flash'

module Transmission
  class App < Sinatra::Base
    register Sinatra::ConfigFile
    register Sinatra::Session

    config = [:app_path => File.dirname(__FILE__)]

    enable :sessions
    enable :method_override
    enable :logging

    use Rack::Flash

    require_relative 'routes/init'
  end
end
