module S3BackupManager
  module PostgresAdapter
  
    def dump_database_to_file(username, database, directory)
      directory = "#{directory}/s3postgresbackup/#{database}"
      FileUtils.mkdir_p(directory)
      system "cd #{directory} && sudo -u #{username} vacuumdb -z #{database} >/dev/null 2>&1"
      exit(1) unless $?.success?
      dump_file = "#{directory}/#{database}.pgsql"
      system "cd #{directory} && sudo -u #{username} pg_dump --blobs --format=t #{database} > #{dump_file}"
      exit(1) unless $?.success?
      user_file = "#{directory}/globals.pgsql"
      system "cd #{directory} && sudo -u #{username} pg_dumpall -v -f #{user_file} --globals-only >/dev/null 2>&1"
      exit(1) unless $?.success?
      [directory]
    end
  
    def restore_database_from_file(username, database, filename)
      # `psql -h localhost -d postgres -U postgres -f "/path/to/useraccts.sql" `
      # exit(1) unless $?.success?
      `sudo -u #{username} pg_restore --format=t -d #{database} #{filename}`
      exit(1) unless $?.success?
    end

    private
      def recreate_database(database)
        `sudo -u postgres dropdb #{database}`
        `sudo -u postgres createdb --encoding=UNICODE #{database}`
      end
    
  end
end