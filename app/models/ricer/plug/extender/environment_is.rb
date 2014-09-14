module Ricer::Plug::Extender::EnvironmentIs
  def environment_is(*environments)
    class_eval do |klass|
      # Sanity
      throw "#{klass.name} environment_is with empty environments." if environments.length == 0
      environments.each{|env|throw "#{klass.name} environment_is not a symbol: #{environments.inspect}" unless env.is_a?(Symbol)}
      # Use "default_enabled" to manage the case
      enabled = environments.include?(Rails.env.to_sym)
      default_enabled enabled
      unless enabled
        # But never allow to enable when not in env!
        def exec_enabled_check!
          raise_disabled_exception
        end
      end
    end
  end
end
