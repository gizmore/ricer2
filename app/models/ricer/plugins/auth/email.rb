module Ricer::Plugins::Auth
  class Email < Ricer::Plugin
  
    def on_upgrade_1; EmailConfirmation.on_upgrade_1; end

    trigger_is :email
    
    permission_is :registered
    
    has_setting name: :valid_for, type: :duration, scope: :bot, permission: :responsible, default: 4.hours, max: 1.month
    
#    pre_execute :execute_cleanup

    has_usage :execute_confirm, '<email> <pin>' 
    has_usage :execute_request, '<email>'
    has_usage :execute_show, ''
    
    def execute_cleanup
      EmailConfirmation.cleanup
    end
    
    def execute_show
      return rply :msg_none if user.email.nil?
      rply :msg_show, email:user.email
    end
    
    def execute_request(address)
      EmailConfirmation.delete_all(:user => user)
      confirmation = EmailConfirmation.new_confirmation(user, address, get_setting(:valid_for))
      return rply :err_address unless confirmation.valid
      confirmation.save!
      send_mail(confirmation)
      nrply :msg_sent, email:address, duration:display_valid_for
    end
    
    def execute_confirm(address, code)
      confirmation = EmailConfirmation.where(user:user, email:address, code:code).first
      return rply :err_code if confirmation.nil?
      user.email = confirmation.email
      user.save!
      confirmation.delete
      return rply :msg_set, email:user.email
    end
    
    private
    
    def send_mail(confirmation)
      to = confirmation.email
      body = t(:mail_body, user:user.nickname, code:confirmation.code, email:to)
      generic_mail(to, t(:mail_subj), body)
    end
    
    def display_valid_for
      lib.human_duration get_setting(:valid_for).show_value
    end
    
  end
end
