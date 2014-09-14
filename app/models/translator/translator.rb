module Translator
  class Translator
    
    def initialize(from=:en, dir=nil)
      @source = from.to_sym
      self.dir = dir if dir
    end
    
    def dir=(dir); create_dir(dir); @dir = dir; end
    def create_dir(dir); FileUtils.mkdir_p(dir); end
    def default_dir; "#{Rails.root}/config/locale_gen"; end
    
    def generate(*targets)
      targets.flatten.each{|target|generate_for(target)}
    end
    
    def generate_for(target)
      self.dir = default_dir unless defined?(@dir)
      target = target.to_sym
      return true if target == @source
      byebug
      I18n.t(:trigger_loading_by_this_lol)
      translations = I18n.backend.instance_variable_get(:@translations)
      translations[target] ||= {}
      sort_translations(translations[@source], translations[target])
      generate_recursive(translations[@source], translations[target])
      save_generated(target, translations[target])
    end
    
    def sort_translations(*hashes)
      hashes.flatten.each{|hash|hash.sort_by_key(true)}
    end
    
    def generate_recursive(source, dest) 
      source.each do |key, src|
        if src.is_a?(Hash)
          dest[key] ||= {}
          generate_recursive(src, dest[key])
        else
          dest[key] = src unless dest[key]
        end
      end
    end
    
    def save_generated(target, dest)
      sort_translations(dest)
      path = "#{@dir}/#{target}.yml"
      File.open(path, 'w') {|f| f.write dest.to_yaml }
    end

    
  end
end