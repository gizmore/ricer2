module Pile
  class Base

    require 'uri'
    
    def initialize(options={})
      @options = options
    end
    
    def upload(title, content, highlighting='text')
      Record.new({
        title: title,
        content: content,
        size: content.length,
        user_id: options[:user_id],
        url: do_upload(title, content, highlighting),
        lang: highlighting,
      })
    end
    
    def do_upload
      throw Exception.new("You need to override 'do_upload' in '#{self.class.name}'. ")
    end

  end
end
