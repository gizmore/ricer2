class BotMailer < ActionMailer::Base

#  default :from => "ricer@ricer.gizmore.org"

  def ricer_from
    Ricer::Application.secrets.mail_smtp_source
  end

  def generic(to, subject, body)
    @body = body
    mail(:from => ricer_from, :to => to, :subject => subject)
  end
  
  def exception(e)
    byebug
    @exception = e
    mail(:from => ricer_from, :to => 'gizmore@gizmore.org', :subject => "[#{Ricer::Bot.instance.name} #{Rails.env}] Exception")
  end
  
end
