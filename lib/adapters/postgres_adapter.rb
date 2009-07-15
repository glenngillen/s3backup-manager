module S3BackupManager
  module PostgresAdapter
  
    def dump_database_to_file(filename, options = {})
      database = options[:database]
      username = options[:username]
      system "sudo -u #{username} vacuumdb -z #{database} >/dev/null 2>&1"
      exit(1) unless $?.success?
      system "sudo -u #{username} pg_dump --blobs --format=t #{database} > #{filename}"
      exit(1) unless $?.success?
    end
  
    def restore_database_from_file(database, filename)
      `sudo -u postgres pg_restore --format=t -d #{database} #{filename}`
    end

    private
      def get_all_databases
        `sudo -u postgres psql -q -c "\\l" | 
         sed -n 4,/\\eof/p | grep -v rows\\) | 
         awk {'print $1'}`.split("\n")
      end
    
      def recreate_database(database)
        `sudo -u postgres dropdb #{database}`
        `sudo -u postgres createdb --encoding=UNICODE #{database}`
      end
    
  end
end