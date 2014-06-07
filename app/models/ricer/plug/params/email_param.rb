module Ricer::Plug::Params
  class EmailParam < StringParam

    def convert_in!(input, options, message)
      begin
        @email = Mail::Address.new(input)
        unless (email.domain) && (email.address == value) && (email.__send__(:tree).domain.dot_atom_text.elements.length > 1)
          failed_input
        end
      rescue => e
        failed_input
      end
      input
    end
    
  end
end
