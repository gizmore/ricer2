require 'openssl'
###
### Allows you to create certs.
### Slso just some description.
###
module Ricer::Plugins::Netcat
  class Netcat < Ricer::Plugin
    
    trigger_is :netcat
    permission_is :responsible

    has_files
    
    # Install SSL Certs unless they exist
    def upgrade_1
      unless plugin_file_exists?('ssl/private_key.pem')
        bot.log_info("Netcat plugin generates RSA keys.")
        key = OpenSSL::PKey::RSA.new 4096
        open plugin_file_path('ssl/private_key.pem'), 'w' do |io| io.write key.to_pem end
        open plugin_file_path('ssl/public_key.pem'), 'w' do |io| io.write key.public_key.to_pem end
      end
    end
    
  end
end
