module S3BackupManager
  module PostgresAdapter
  
    def dump_database_to_file(username, database, directory)
      directory = "#{directory}/s3postgresbackup/#{database}"
      FileUtils.mkdir_p(directory)
      FileUtils.chmod_R 0770, directory
      FileUtils.chown_R nil, username, directory
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
  
    def restore_database_from_file(username, database, directory)
      system "chown -R #{username} #{config[:temp_dir]}/#{database}"
      user_file = "#{directory}/globals.pgsql"
      system "cd #{config[:temp_dir]} && sudo -u #{username} psql -f #{user_file} >/dev/null 2>&1"
      unless $?.success?
        puts "Unable to load in the users"
        exit(1) 
      end
      dump_file = "#{directory}/#{database}.pgsql"
      recreate_database!(username, database)
      system "cd #{config[:temp_dir]} && sudo -u #{username} pg_restore --format=t -d #{database} #{dump_file} >/dev/null 2>&1"
      unless $?.success?
        puts "Unable to restore database. Did you provide a username that has permission?"
        exit(1) 
      end
    end

    private
      def recreate_database!(username, database)
        system "cd #{config[:temp_dir]} && sudo -u #{username} createdb --encoding=UNICODE #{database} > /dev/null 2>&1"
      end
    
  end
end