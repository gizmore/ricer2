# Query Counter for mysql2 adapter
module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      @@querycount = 0
      attr_reader :querycount
      def self.querycount; @@querycount; end
    end
    class Mysql2Adapter < AbstractMysqlAdapter
      def exec_query(sql, name = 'SQL', binds = [])
        @@querycount += 1
        @querycount = 0 if @querycount.nil?
        @querycount += 1
        result = execute(sql, name)
        ActiveRecord::Result.new(result.fields, result.to_a)
      end
    end
  end
end

