require 'yaml'
module Ricer::Plugins::Slapwarz
  class Slapwarz < Ricer::Plugin
    
    def upgrade_1
      Model::Hit.upgrade_1
      Model::Word.upgrade_1
    end

    def plugin_init
      @recalc_needed = true
      install_items
      recalculate_history if @recalc_needed
    end
    
    def install_items
      data = YAML.load_file(plugin_dir+'/data/slaps.yml')
      install_item_group(data["adverbs"], Model::Word::ADVERB)
      install_item_group(data["verbs"], Model::Word::VERB)
      install_item_group(data["adjectives"], Model::Word::ADJECTIVE)
      install_item_group(data["objects"], Model::Word::OBJECT)
    end
    
    def install_item_group(data, type)
      data.each_pair do |name, damage|
        install_item(name, damage, type)
      end
    end
    
    def install_item(name, damage, type)
      item = Model::Word.where("name=? AND slaptype=?", name, type).first
      if item
        @recalc_needed = true if item.damage != damage
      else
        bot.log_info("New slap item: #{name} with #{damage} damage.")
        item = Model::Word.create!({:name => name, :slaptype => type, :damage => damage})
      end
      item
    end
    
    def recalculate_history
      
    end
    
  end
end
