module Ricer::Plug::Params
  class UrlParam < Base
    
    ALL_SCHEMES = [] # TODO

    def schemes
      ['http', 'https']
    end

    def default_options
      { schemes: schemes }
    end
    
    def scheme_options
      options[:schemes].is_a?(String) ?
        (options[:schemes].split(/\s*[,;:]+\s*/).reject{|r|r.empty?}) :
        options[:schemes]
    end

    def convert_in!(input, message)
      uri = URI(input)
      scheme_options.include?(uri.scheme) or failed_uri(uri)
      input
    end
    
    def failed_uri(scheme)
      scheme ?
        failed(:err_scheme, scheme: scheme, schemes: lib.join(scheme_options)) :
        failed(:err_urifmt)
    end
    
    def convert_out!(url_string, message)
      url_string.to_s
    end
    
  end
end
