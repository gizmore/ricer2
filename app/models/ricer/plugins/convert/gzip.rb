module Ricer::Plugins::Convert
  class Gzip < Ricer::Plugin

    trigger_is :gzip

    has_usage '<..data..>'
    def execute(data)
      begin
        zstream = Zlib::Inflate.new
        reply zstream.inflate(data)
      ensure
        zstream.finish
        zstream.close
      end
    end

  end
end
