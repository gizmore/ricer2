module Ricer::Plugins::Quote
  class Delete < Ricer::Plugin

    trigger_is :delete

    permission_is :halfop

    has_usage '<id>'
    def execute(id)
      quote = Model::Quote.find(id)
      quote.delete
      rply :msg_deleted, :id => quote.id
    end

  end
end
