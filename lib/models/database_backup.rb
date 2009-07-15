require "#{File.dirname(__FILE__)}/file_backup"
require "#{File.dirname(__FILE__)}/../lib/mysql_adapter"
require "#{File.dirname(__FILE__)}/../lib/postgres_adapter"
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
      databases = get_all_databases(@options) if database == :all
      databases ||= [database]
      databases.each do |db|
        filename = "/tmp/#{db}"
        dump_database_to_file(filename, @options)
        super(filename, "databases/#{@options[:adapter]}")
      end
    end
  
    def restore(database, timestamp)
      databases = get_all_databases(@options) if databases == :all
      databases ||= [database]
      databases.each do |db|
        filename = "#{@options[:adapter]}/#{timestamp}/#{db}"
        super(filename, timestamp)
        restore_database_from_file(filename, @options)
      end
    end
  end
end