#
# Enable a global cache table for active record models.
# Does slow everything down a bit!
#
module ActiveRecord

  class Base
    def self.global_cache
      ActiveRecord::Base.instance_variable_get(:@CURRY_CACHE)[table_name]
    end
    def self.with_global_orm_mapping()
      class_eval do |klass|
        # klass.class_variable_set('@@CACHE', {}) unless klass.class_variable_defined?('@@CACHE')
        caches = ActiveRecord::Base.instance_variable_defined?(:@CURRY_CACHE) ? 
          ActiveRecord::Base.instance_variable_get(:@CURRY_CACHE) :
          ActiveRecord::Base.instance_variable_set(:@CURRY_CACHE, {})
        caches[klass.table_name] ||= {}
        def global_cache
          self.class.global_cache
#          self.class.class_variable_get('@@CACHE')
        end
        def global_cache_table(record)
          c, rid = global_cache, record.global_cache_key
          c[rid] ||= record if record.should_cache?
#          record = c[record.id] || record; puts "Curry#get_cached: '#{record.class.name}'#{record.global_cache_key} with object_id #{record.object_id}." ## DEBUG
          c[rid] || record
        end
        def global_cache_add
#          puts "Curry#global_cache_add: '#{self.class.name}'#{self.global_cache_key} with object_id #{self.object_id}."
          global_cache_table(self)
        end
        def global_cache_remove
#          puts "Curry#global_cache_remove: '#{self.class.name}'#{self.global_cache_key} with object_id #{self.object_id}."
          global_cache.delete(self.global_cache_key)
        end
        def global_cache_key
          self.id
        end
      end
    end
  end

  class Relation
    
    alias :original_exec_queries :exec_queries # alias to override
    
    # XXX: SLOOOW!
    def exec_queries
      begin
        new_records = []
        original_exec_queries.each do |record| # call overridden
          break unless record.respond_to? :global_cache_table
          new_records.push(record.global_cache_table(record))
        end
        @records = new_records unless new_records.empty?
      rescue StandardError => e
        puts "OOOPS: #{e.to_s}\n\n#{e.backtrace}\nSLEEPING 20 seconds for penalty!!!"
      end
      @records
    end
    
  end
end
