module MysqlAdapter
  
  def dump_all_databases_to_file(filename)
    # `mysqldump --user=root --password=yourrootsqlpassword --lock-all-tables \
    #       --all-databases > #{filename}`
  end
  
  def dump_database_to_file(database, filename)
    # `mysqldump --opt -h hostname -u user -p password #{database} > #{filename}`
  end
  
  def restore_database_from_file(database, filename)
    # `mysql - u user_name -p your_password #{database} < #{filename}`
  end
  
  private
    def get_all_databases
      # `mysql -u root -h localhost -ppassword -Bse 'show databases'`
    end
    
    def recreate_database(database)
    end
end