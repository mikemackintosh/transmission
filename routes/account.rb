module Transmission
  class App
  	
  	get '/login' do
  		if session['username']
  			redirect "/"
  		end

  		erb :login
  	end

  	post '/login' do
   		if check_ssh_key( params['username'], params['password'] )
   			status 200
  			session['username'] = params['username']
   			redirect '/'
   		else
   			session = []
   			status 403
   			redirect back
   		end
  	end

  	# Sign Up page
  	get '/signup' do
  		
  		if session['username']
  			redirect "/"
  		end

  		erb :signup
  	end

  	post '/signup' do

  		# Param validation
  		params.each do |key, value|
  			if value.nil?
  				flash[:failure] = "Please enter a value for #{key}!"
  			end
  		end

  		# Make sure you have passwords that match
   		if params['password'] == params['confirm_password']
   			create_ssh_key( params['username'], params['password'], params['email'])
   			
   			session['username'] = params['username']
   			session['email'] = params['email']
   			flash[:success] = "Account successfully created!"

   			redirect '/'

   		else
   			flash[:failure] = "Please confirm your password!"
   		end

   		redirect back

 	end

  end

end
