module ActiveRecord

  class Base
    def self.with_global_orm_mapping
      class_eval do |cl|
        cl.class_variable_set('@@CACHE', {}) unless cl.class_variable_defined?('@@CACHE')
        def global_cache_table(record)
          c = self.class.class_variable_get('@@CACHE')
          c[record.id] ||= record if record.should_cache?
#          record = c[record.id] || record ## DEBUG
#          puts "Curry#get_cached: '#{record.class.name}'#{record.id} with object_id #{record.object_id}." ## DEBUG
#          record ## DEBUG
          c[record.id] || record
        end
        def self.global_cache
          self.class.class_variable_get('@@CACHE')
        end
        def global_cache_add
#          puts "Curry#global_cache_add: '#{self.class.name}'#{self.id} with object_id #{self.object_id}."
          global_cache_table(self)
        end
        def global_cache_remove
#          puts "Curry#global_cache_remove: '#{self.class.name}'#{self.id} with object_id #{self.object_id}."
          self.class.global_cache.delete(self.id)
        end
      end
    end
  end

  class Relation
    
    alias :original_exec_queries :exec_queries
    
    def exec_queries
      begin
        new_records = []
        original_exec_queries.each do |record|
          break unless record.respond_to? :global_cache_table
          new_records.push(record.global_cache_table(record))
        end
        @records = new_records unless new_records.empty?
      rescue => e
        #puts "OOOPS: #{e.to_s}\n\n#{e.backtrace}\n"
      end
      @records
    end
    
  end
end
