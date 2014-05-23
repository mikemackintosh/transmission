require_relative '../helpers/system'

module Transmission
  class App
    get '/account' do
      create_key = create_ssh_key('mike')
    end
  end
end
