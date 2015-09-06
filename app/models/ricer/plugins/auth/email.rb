module Ricer::Plugins::Auth
  class Email < Ricer::Plugin
  
    def upgrade_1; EmailConfirmation.upgrade_1; end

    trigger_is :email
    
    permission_is :registered
    
    has_setting name: :valid_for, type: :duration, scope: :bot, permission: :responsible, default: 4.hours, max: 1.month, integer: true
    
    has_usage :execute_confirm, '<email> <pin>' 
    has_usage :execute_request, '<email>'
    has_usage :execute_show, ''
    
    def execute_show
      return rply :msg_none if user.email.nil?
      rply :msg_show, email:user.email
    end
    
    def execute_request(address)
      # Clean for user
      EmailConfirmation.delete_all(:user_id => user.id)
      # Create one for user
      confirmation = EmailConfirmation.create!(
        user: user,
        code: Ricer::Plug::Pin.random_pin.to_value,
        email: address.to_s,
        expires: valid_until
      )
      # Send mail
      send_confirmation_mail(confirmation)
      # And tell him
      nrply :msg_sent, email: address, duration: show_setting(:valid_for)
    end
    
    def execute_confirm(address, pin)
      confirmation = EmailConfirmation.not_expired.where(user:user, email:address.to_s, code:pin.to_value).first
      return rply :err_code if confirmation.nil?
      user.email = confirmation.email
      user.save!
      confirmation.delete
      return rply :msg_set, email:user.email
    end
    
    private
    
    def valid_until
      Time.now + get_setting(:valid_for)
    end
    
    def send_confirmation_mail(confirmation)
      to = confirmation.email
      subj = t(:mail_subj)
      body = t(:mail_body, user:user.nickname, code: confirmation.code, email:to)
      send_mail(to, subj, body)
    end
    
  end
end
