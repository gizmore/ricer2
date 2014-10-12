module Ricer::Plugins::Convert
  class Gunzip < Ricer::Plugin

    trigger_is :gunzip

    has_usage '<..text..>'
    def execute(text)
      begin
        text.force_encoding('binary')
        z = Zlib::Inflate.new
        reply = zstream.inflate(text)
      ensure
        z.finish
        z.close
      end
    end

  end
end
