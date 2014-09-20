module Ricer::Plugins::Convert
  class Gunzip < Ricer::Plugin

    trigger_is :gunzip

    has_usage '<..data..>'
    def execute(data)
      begin
        data.force_encoding('binary')
        zstream = Zlib::Deflate.new
        reply zstream.deflate(data)
      ensure
        zstream.finish
        zstream.close
      end
    end

  end
end
