# Query Counter for mysql2 adapter
module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      @@querycount = 0
      @@db_time = 0.0
      attr_reader :querycount
      def self.querytime; @@db_time; end
      def self.querycount; @@querycount; end
    end
    class Mysql2Adapter < AbstractMysqlAdapter

      def execute(sql, name = nil)
        @@querycount += 1
        @querycount ||= 0
        @querycount += 1
        if @connection
          @connection.query_options[:database_timezone] = ActiveRecord::Base.default_timezone
        end
        super
      end

      def exec_query(sql, name = 'SQL', binds = [])
        before = Time.now.to_f
        result = execute(sql, name)
        result_set = ActiveRecord::Result.new(result.fields, result.to_a)
        @@db_time += Time.now.to_f - before
        result_set
      end
    end
  end
end

