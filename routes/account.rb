module Transmission
  class App
    get '/account' do
      #create_key = create_ssh_key("mike", "thisisapassword", "m@zyp.io")
      check_ssh_key("mike", "thisisapassword")
    end
  end
end
