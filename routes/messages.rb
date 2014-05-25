module Transmission
  class App
  	
    get '/messages' do
      @messages = []
      @users = []
      Dir["#{settings.app_path}/messages/#{session['username']}*"].each do |messages|
        msg = /(.*)_(.*)_(.*)/.match(messages).to_s.split("_")
        puts msg.inspect
        message = {}
        message[:id] = Digest::MD5.hexdigest(msg[0])
        message[:from] = msg[1]
        message[:date] = msg[2]
        message[:status] = File.read(messages).to_s[-2,2].include?('0') ? 'unread' : 'read'
        puts message
        @messages.push(message)
      end

      erb :messages
    end

    get '/message/:msgid' do
      @uri = "#{request.path}?#{request.query_string}"
      erb :message_auth
    end

    post '/message/:msgid' do
      message = {}
      Dir["#{settings.app_path}/messages/#{session['username']}*"].each do |messages|
        msg = /(.*)_(.*)_(.*)/.match(messages).to_s.split("_")
        if params[:msgid] == Digest::MD5.hexdigest(msg[0])
          message[:from] = msg[1]
          message[:date] = msg[2]
          secure_message = File.read(messages).to_s[0..-3]
          private_key = OpenSSL::PKey::RSA.new(File.read("#{settings.app_path}/keys/#{session['username']}_rsa"), params[:password])
          content = private_key.private_decrypt Base64.decode64(secure_message)

          # Set Read Flag
          File.open(messages, 'w') { |file| 
            file.write("#{secure_message} ,1") 
          }

          message[:content] = content
          @message = message          
        end
      end

      erb :message
          
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
      Dir["#{settings.app_path}/keys/*_rsa.pub"].each do |pub_files|
        user = /([A-Za-z0-9]+)_rsa/.match(pub_files).to_s.split('_')
        @users.push(user[0])
      end

      target_user = params['user']

      target_public_key = "#{settings.app_path}/keys/#{target_user}_rsa.pub"
      target_private_key = "#{settings.app_path}/keys/#{target_user}_rsa"

      public_key = OpenSSL::PKey::RSA.new File.read target_public_key
      
      secure =  public_key.public_encrypt( params['message'] )
      timestamp = Time.now.utc.to_i

      # Write Message
      File.open("#{settings.app_path}/messages/#{target_user}_#{session['username']}_#{timestamp}", 'w') { |file| 
        message = Base64.encode64(secure)
        file.write( "#{message},0")
      }
      
      flash[:success] = "Message sent to #{target_user}!"

      erb :send
    end

  end
end
