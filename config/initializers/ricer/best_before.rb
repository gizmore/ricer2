module ActiveRecord
  class Base
    def validate!
      raise(RecordInvalid.new(self)) if invalid?
      true
    end
  end
end
