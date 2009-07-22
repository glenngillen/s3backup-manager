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
      directory = "/tmp/#{database}"
      files = dump_database_to_file(@options[:username], database, directory)
      super(files, "databases/#{@options[:adapter]}")
      files.each do |file|
        FileUtils.rm_r(file)
      end
    end

    def restore(database, timestamp)
      filename = "#{@options[:adapter]}/#{timestamp}/#{database}"
      @dumped_filename = "/tmp/#{random_string}"
      super(filename, timestamp, @dumped_filename, "databases")
      restore_database_from_file(@options[:username], database, "#{@dumped_filename}/tmp/#{database}")
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