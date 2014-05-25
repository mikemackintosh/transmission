module Transmission
  class App
  	
  	get '/login' do
  		erb :login
  	end

  	post '/login' do
   		if check_ssh_key( params['username'], params['password'] )
   			status 200
  			session['username'] = params['username']
   			redirect '/account'
   		else
   			status 403
   			redirect back
   		end
  	end

  	# Sign Up page
  	get '/signup' do
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

   			redirect '/account'

   		else
   			flash[:success] = "Please confirm your password!"
   		end

   		redirect back

 	end

  	# Account Details Page
    get '/account' do

    end


  end
end
