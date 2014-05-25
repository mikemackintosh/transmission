module Transmission
  class App
  	
    get '/messages' do
      
      @users = []
      Dir["#{settings.app_path}/messages/#{session['username']}*"].each do |pub_files|
        #user = /([A-Za-z0-9]+)_rsa/.match(pub_files).to_s.split('_')
        #@users.push(user[0])
      end

      erb :messages
    end

    get '/message/:name' do
      #private_key = OpenSSL::PKey::RSA.new(File.read(target_private_key), passphrase)
      #original_key = private_key.private_decrypt secure
    end

    get '/send' do
      @users = []
      Dir["#{settings.app_path}/keys/*_rsa.pub"].each do |pub_files|
        user = /([A-Za-z0-9]+)_rsa/.match(pub_files).to_s.split('_')
        @users.push(user[0])
      end
      erb :send
    end

    post '/send' do
      @users = []
      target_user = params['user']

      target_public_key = "#{settings.app_path}/keys/#{target_user}_rsa.pub"
      target_private_key = "#{settings.app_path}/keys/#{target_user}_rsa"

      public_key = OpenSSL::PKey::RSA.new File.read target_public_key
      
      secure =  public_key.public_encrypt( params['message'] )
      timestamp = Time.now.utc.to_i

      # Write Message
      File.open("#{settings.app_path}/messages/#{target_user}_#{session['username']}_#{timestamp}", 'w') { |file| 
        file.write(Base64.encode64(secure)) 
      }
      
      flash[:success] = "Message sent to #{target_user}!"

      erb :send
    end

  end
end
