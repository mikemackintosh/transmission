module Transmission
  class App
  	
    get '/messages' do
      erb :messages
    end

    get '/send' do
      erb :send
    end


    def get_users 
      
    end
  end
end
