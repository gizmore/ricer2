module Ricer::Plugins::Data
  class Weather < Ricer::Plugin

    trigger_is :weather

    has_usage '<..message..>'
    def execute(input)
      Ricer::Thread.execute do 
        begin
          url = "http://api.openweathermap.org/data/2.5/weather?q=#{URI::encode(input)}&units=metric&lang=#{best_owm_lang}"
          data = Net::HTTP.get(URI.parse(url))
          json = JSON.parse!(data)
          if json["cod"].to_i != 200
            rply :err_location
          else
            rply(:msg_openweather,
              city: json["name"],
              country: json["sys"]["country"],
              temp_avg: lib.human_fraction(json["main"]["temp"]),
              temp_min: lib.human_fraction(json["main"]["temp_min"]),
              temp_max: lib.human_fraction(json["main"]["temp_max"]),
            )
          end
        rescue StandardError => e
          bot.log_exception(e)
          return rply :err_connect, reason: e.to_s
        end
      end
    end
    
    def best_owm_lang
      # TODO: Map the best choice for users locale
      # AVAILABLE IN OWM:
      # English - en, Russian - ru, Italian - it, Spanish - es (or sp)
      # Ukrainian - uk (or ua), German - de, Portuguese - pt, Romanian - ro,
      # Polish - pl, Finnish - fi, Dutch - nl, French - fr, Bulgarian - bg
      # Swedish - sv (or se), Chinese Traditional - zh_tw, Chinese Simplified - zh (or zh_cn)
      # Turkish - tr, Croatian - hr, Catalan - ca 
      "de"
    end
    
  end
end
