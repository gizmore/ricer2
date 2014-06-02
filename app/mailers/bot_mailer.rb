class BotMailer < ActionMailer::Base

  default :from => "ricer@ricer.gizmore.org"

  def generic(to, subject, body)
    @body = body
    mail(:to => to, :subject => subject)
  end
  
  def exception(e)
    @exception = e
    mail(:to => 'gizmore@gizmore.org', :subject => "[Ricer #{Rails.env}] Exception")
  end
  
end
