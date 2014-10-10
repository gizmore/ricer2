###
### Limit a plugin to rails environments.
###
### @example environment_is :development
### @example environment_is [:development, :test, :production]
###
module Ricer::Plug::Extender::EnvironmentIs
  def environment_is(*environments)
    # Sanity
    environments.each{|env|throw "#{klass.name} environment_is not a symbol: #{environments.inspect}" unless env.is_a?(Symbol)}
    throw "#{klass.name} environment_is with empty environments." if environments.length == 0
    # End of sanity

    # We abuse the "default_enabled" extender
    # In case we run a wrong env, we just always call it´s exception raiser.
    class_eval do |klass|
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
