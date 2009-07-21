module S3BackupManager
  class DatabaseBackup < FileBackup
    def initialize(opts = {})
      @options = opts
      super
      case @options[:adapter]
      when "postgres"
        self.extend S3BackupManager::PostgresAdapter
      when "mysql"
        self.extend ::S3BackupManager::MysqlAdapter
      when "couchdb"
        self.extend ::S3BackupManager::PostgresAdapter
      end
      self
    end
    
    def files
      bucket.files.select{|f| f.key.match(%r{^databases/})}
    end
  
    def backup(database)
      filename = "/tmp/#{database}"
      dump_database_to_file(filename, @options.merge(:database => database))
      super(filename, "databases/#{@options[:adapter]}")
    end

    def restore(database, timestamp)
      filename = "#{@options[:adapter]}/#{timestamp}/#{database}"
      @dumped_filename = "/tmp/#{random_string}"
      super(filename, timestamp, @dumped_filename, "databases")
      restore_database_from_file(@dumped_filename, @options)
      db_cleanup!
    end
    
    private
      def db_cleanup!
        if @dumped_filename
          File.delete(@dumped_filename) 
          @dumped_filename = nil
        end
      end
  end
end