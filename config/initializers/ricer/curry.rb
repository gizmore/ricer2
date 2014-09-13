#
# Enable a global cache table for active record models.
# Does slow everything down a bit!
#
module ActiveRecord

  class Base
    def self.with_global_orm_mapping
      class_eval do |klass|
        # klass.class_variable_set('@@CACHE', {}) unless klass.class_variable_defined?('@@CACHE')
        caches = ActiveRecord::Base.instance_variable_defined?(:@CURRY_CACHE) ? 
          ActiveRecord::Base.instance_variable_get(:@CURRY_CACHE) :
          ActiveRecord::Base.instance_variable_set(:@CURRY_CACHE, {})
        caches[klass.table_name] ||= {}
        def global_cache
          ActiveRecord::Base.instance_variable_get(:@CURRY_CACHE)[self.class.table_name]
#          self.class.class_variable_get('@@CACHE')
        end
        def global_cache_table(record)
          c = global_cache
          c[record.id] ||= record if record.should_cache?
#          record = c[record.id] || record; puts "Curry#get_cached: '#{record.class.name}'#{record.id} with object_id #{record.object_id}." ## DEBUG
          c[record.id] || record
        end
        def global_cache_add
#          puts "Curry#global_cache_add: '#{self.class.name}'#{self.id} with object_id #{self.object_id}."
          global_cache_table(self)
        end
        def global_cache_remove
#          puts "Curry#global_cache_remove: '#{self.class.name}'#{self.id} with object_id #{self.object_id}."
          global_cache.delete(self.id)
        end
      end
    end
  end

  class Relation
    
    alias :original_exec_queries :exec_queries # alias to override
    
    # SLOOOW
    def exec_queries
      begin
        new_records = []
        original_exec_queries.each do |record| # call overridden
          break unless record.respond_to? :global_cache_table
          new_records.push(record.global_cache_table(record))
        end
        @records = new_records unless new_records.empty?
      rescue StandardError => e
        puts "OOOPS: #{e.to_s}\n\n#{e.backtrace}\n"
      end
      @records
    end
    
  end
end
