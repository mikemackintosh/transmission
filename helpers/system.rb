module Transmission
  class SystemHelper
    def create_ssh_key( user )
      %x[ssh-keygen -t rsa -b 4093 -q -C "Key for user: #{user}" -f #{@config.app_path}/keys/#{user}_rsa ]
    end
  end
end
