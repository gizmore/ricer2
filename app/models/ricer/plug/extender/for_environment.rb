module Ricer::Plug::Extender::ForEnvironment
  def for_environment(*environments)
    class_eval do |klass|
      default_enabled environments.include?(ENV['RAILS_ENV'])
    end
  end
end
