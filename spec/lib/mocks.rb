module S3BackupManager
  module Mocks
    
    def mock_bucket
      stub_aws
      stub_bucket_find
      @bucket.stub!(:store)
    end
    
    def mock_filesystem_files
      @lines = mock("lines")
      @lines.stub!(:each).and_yield(["my data here"])
      @lines.stub!(:write)
    end
    
    def mock_filebackup_dependencies
      mock_filesystem_files
      @encrypter = mock("aes", :key= => nil, :iv= => nil, :final => nil)
      @encrypter.stub!(:encrypt)
      @encrypter.stub!(:decrypt)
      OpenSSL::Cipher::Cipher.stub!(:new).with("AES-256-CBC").and_return(@encrypter)
      
      FileBackup.stub!(:open)
      File.stub!(:delete)
      Zlib::GzipWriter.stub!(:new)
      Zlib::GzipReader.stub!(:new)
      Archive::Tar::Minitar.stub!(:pack)
    end
    
    def mock_backup_files
      files = [mock("aws_object", :key => "filesystem/filename1.txt"),
               mock("aws_object", :key => "filesystem/filename2.txt"),
               mock("aws_object", :key => "filesystem/filename3.txt"),
               mock("aws_object", :key => "databases/db1.txt"),
               mock("aws_object", :key => "databases/db2.txt")]
      @bucket.stub!(:files).and_return(files)
    end
    
    def stub_aws
      stub_bucket_config
      stub_aws_connection
    end
    
    def stub_bucket_config
      YAML.stub!(:load_file).with(
        "/etc/s3backup-manager/config.yml").and_return(
        {"aws_access_key_id" => "unique_key_id",
         "aws_secret_access_key" => "sekret_keyz",
         "encryption_secret" => "hrrmm_how_secret?",
         "collection_prefix" => "backup_collection_name"})
    end
    
    def stub_aws_connection
      AWS::S3::Base.stub!(:establish_connection!)
    end
    
    def stub_bucket_find
      @bucket = mock("bucket")
      Bucket.stub!(:find).and_return(@bucket)
    end
    
    def stub_aws_find
      AWS::S3::Bucket.stub!(:find).and_return(mock("aws_bucket"))
    end
    
  end
end