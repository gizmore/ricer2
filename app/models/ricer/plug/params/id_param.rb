module Ricer::Plug::Params
  class IdParam < IntegerParam

    def default_options
      { min: 1, max: 2123123123 }
    end

  end
end
