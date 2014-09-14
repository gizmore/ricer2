# Create huge lang files from the :en: snippets cluttered along the app
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
      I18n.t(:trigger_loading_by_this_lol)
      translations = I18n.backend.instance_variable_get(:@translations)
      translations[target] ||= {}
      save_generated(target, translations[target])
      sort_translations(translations[@source], translations[target])
      generate_recursive(translations[@source], translations[target])
      save_generated(target, translations[target], '_huge_')
    end
    
    def sort_translations(*hashes)
      hashes.flatten.each{|hash|hash.sort_by_key(true) unless hash.nil?}
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
    
    def save_generated(target, dest, prefix='')
      sort_translations(dest)
      dest = nil if dest.empty?
      path = "#{@dir}/#{prefix}#{target}.yml"
      File.open(path, 'w') {|f| f.write({target => dest}.to_yaml) }
    end
    
  end
end
