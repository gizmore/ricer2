module Ricer::Plugins::Convert
  class Gzip < Ricer::Plugin

    trigger_is :gzip
    
    has_setting name: :level, type: :integer, scope: :user, permission: :public, min: 1, max: 9, default: 6

    has_usage '<..text..>'
    def execute(text)
      begin
        z = Zlib::Deflate.new(get_setting(:level))
        reply z.deflate(text, Zlib::FINISH)
      ensure
        z.close
      end
    end

  end
end
