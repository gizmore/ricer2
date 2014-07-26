module Ricer::Plug::Params
  class IdParam < IntegerParam

    def min(options)
      options[:min].nil? || options[:min].is_not_a?(Integer) ? 1 : options[:min]
    end

  end
end
