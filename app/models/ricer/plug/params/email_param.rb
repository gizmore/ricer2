module Ricer::Plug::Params
  class EmailParam < StringParam

    def convert_in!(input, message)
      begin
        email = Mail::Address.new(input)
        failed_input unless (email.domain) && (email.address == input) && (email.__send__(:tree).domain.dot_atom_text.elements.length > 1)
        email
      rescue StandardError => e
      end
      failed_input
    end
    
    def convert_out!(email, message)
      email.to_s
    end
    
  end
end
