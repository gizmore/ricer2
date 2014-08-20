###
### Adds :charset and :collation options to activerecord column definitions.
###
### License: ?
### Author: Ryuta Kamizono
### Stolen from: http://qiita.com/kamipo/items/4763bcffce2140f030b3
###
### Tested with
### ActiveRecord: 4.1.1
###
###
ActiveSupport.on_load :active_record do
  module ActiveRecord::ConnectionAdapters
    class AbstractMysqlAdapter
      class ColumnDefinition < ActiveRecord::ConnectionAdapters::ColumnDefinition
        attr_accessor :charset, :collation
      end
  
      class TableDefinition < ActiveRecord::ConnectionAdapters::TableDefinition
        def column(name, type = nil, options = {})
          super
          column = self[name]
          column.charset   = options[:charset]
          column.collation = options[:collation]
  
          self
        end
  
        private
  
        def create_column_definition(name, type)
          ColumnDefinition.new name, type
        end
      end
  
      class SchemaCreation < AbstractAdapter::SchemaCreation
        def column_options(o)
          column_options = super
          column_options[:charset]   = o.charset unless o.charset.nil?
          column_options[:collation] = o.collation unless o.collation.nil?
          column_options
        end
  
        def add_column_options!(sql, options)
          if options[:charset]
            sql << " CHARACTER SET #{options[:charset]}"
          end
  
          if options[:collation]
            sql << " COLLATE #{options[:collation]}"
          end
  
          super
        end
      end
  
      class Column < ActiveRecord::ConnectionAdapters::Column
        attr_reader :charset
  
        def initialize(name, default, sql_type = nil, null = true, collation = nil, strict = false, extra = "")
          @strict    = strict
          @collation = collation
          @charset   = collation.sub(/_.*\z/, '') unless collation.nil?
          @extra     = extra
          super(name, default, sql_type, null)
        end
      end
  
      def prepare_column_options(column, types)
        spec = super
        conn = ActiveRecord::Base.connection
        spec[:charset]   = column.charset.inspect if column.charset && column.charset != conn.charset
        spec[:collation] = column.collation.inspect if column.collation && column.collation != conn.collation
        spec
      end
  
      def migration_keys
        super + [:charset, :collation]
      end
  
      private
  
      def create_table_definition(name, temporary, options, as=nil)
        TableDefinition.new native_database_types, name, temporary, options, as
      end
    end
  end
end
