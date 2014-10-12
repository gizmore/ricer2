module Ricer::Plugins::Art
  class Fu < Ricer::Plugin
    trigger_is :fu
    has_usage :execute
    def execute
      reply '┌∩┐(◣_◢)┌∩┐' #'︻╦╤─'
    end
  end
end
