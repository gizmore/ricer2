# Define byebug for production, in case the devs accidently left a byebug call
unless Object.respond_to?(:byebug)
  class Object
    def byebug
      # Nothing todo :)
    end
  end
end
