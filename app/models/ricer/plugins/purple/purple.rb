module Ricer::Plugins::Purple
  class Purple < Ricer::Plugin
    
    #########################
    ### Connected Servers ###
    #########################    
    # Here we will store the purple/violet connections
    def on_init 
      @@servers = {}
    end

    def add_purple_server(account, server)
      key = account.protocol_id + account.username
      @@servers[key] = server
    end
    
    ##########################################################
    ### Delegate GTK mainloop events to the correct Server ###
    ##########################################################
    def violet_server(account)
      key = account.protocol_id + account.username
      @@servers[key]
    end

    def violet_connection(account)
      violet_server(account).connection
    end
    
    def delegate(method_name, *method_args)
      begin
        connection = violet_connection(method_args[0])
        connection.send(method_name, *method_args) if connection.respond_to?(method_name)
      rescue Exception => e
        bot.log_exception(e)
      end
    end

    ################
    ### Mainloop ###
    ################    
    # After all is connecting, init gtk mainloop
    # It is not done when there is no violet connection at all
    def ricer_on_global_startup
      
      return if @@servers.empty? # Nothing to do ~o´
      
      #handle incoming im messages
      PurpleRuby.watch_incoming_im do |acc, sender, message|
        bot.log_debug "PurpleRuby.watch_incoming_im: #{acc.username} #{sender}: #{message}"
        delegate(:watch_incoming_im, acc, sender, message)
      end
      
      PurpleRuby.watch_signed_on_event do |acc| 
        bot.log_debug "PurpleRuby.watch_signed_on_event: #{acc.username}"
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

      # Whatever?
      PurpleRuby.watch_notify_message do |type, title, primary, secondary|
        puts "notification: #{type}, #{title}, #{primary}, #{secondary}"
#        delegate(:watch_notify_message, type, title, primary, secondary)
      end
      mainloop
    end
    #
    # The mainloop is stepping in g_main_loop
    # This way we have no problems with threading in gtk
    def mainloop
      Ricer::Thread.execute do |t|
        loop do
          sleep 0.200
          PurpleRuby.main_loop_step
        end
      end
    end

  end
end
