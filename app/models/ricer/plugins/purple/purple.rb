module Ricer::Plugins::Purple
  
  PurpleRuby.init :debug => true, :user_dir => "#{Rails.root}/tmp/purple_users"
  puts "Available protocols:", PurpleRuby.list_protocols

  class Purple < Ricer::Plugin
    
    def violet_server(account)
      key = account.protocol_id + account.username
      @servers[key]
    end

    def violet_connection(account)
      violet_server(account).connection
    end
    
    def add_purple_server(account, server)
      key = account.protocol_id + account.username
      @servers[key] = server
    end
    
    def delegate(method_name, *args)
      begin
        connection = violet_connection(args[0])
        connection.send(method_name, *args) if connection.respond_to?(method_name)
      rescue Exception => e
        bot.log_exception(e)
      end
    end
    
    subscribe('ricer/on/exit') do |bot|
      # PurpleRuby.main_loop_stop
    end
    
    def on_init
      
      @servers = {}
      
      #handle incoming im messages
      PurpleRuby.watch_incoming_im do |acc, sender, message|
        puts "message: #{acc.username} #{sender}: #{message}"
        delegate(:watch_incoming_im, acc, sender, message)
      end
      
      PurpleRuby.watch_signed_on_event do |acc| 
        puts "signed on: #{acc.username}"
        delegate(:watch_signed_on_event, acc)
      end
      
      PurpleRuby.watch_connection_error do |acc, type, description| 
        puts "connection_error: #{acc.username} #{type} #{description}"
        delegate(:watch_connection_error, acc, type, description) || false
        #'true': auto-reconnect; 'false': do nothing
      end
      
      #request can be: 'SSL Certificate Verification' etc
      PurpleRuby.watch_request do |title, primary, secondary, who|
        puts "request: #{title}, #{primary}, #{secondary}, #{who}"
        delegate(:watch_request, who, title, primary, secondary) || false
        #'true': accept a request; 'false': ignore a request
      end
      
      #request for authorization when someone adds this account to their buddy list
      PurpleRuby.watch_new_buddy do |acc, remote_user, message| 
        puts "new buddy: #{acc.username} #{remote_user} #{message}"
        delegate(:watch_new_buddy, acc, remote_user, message) || true
        #'true': accept; 'false': deny
      end
      
      PurpleRuby.watch_notify_message do |type, title, primary, secondary|
        puts "notification: #{type}, #{title}, #{primary}, #{secondary}"
#        delegate(:watch_notify_message, type, title, primary, secondary)
      end
      
      Ricer::Thread.execute do |t|
        loop do
          sleep 0.2
          PurpleRuby.main_loop_step
        end
      end

    end

  end
end
