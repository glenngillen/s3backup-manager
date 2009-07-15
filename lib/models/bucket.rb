module S3BackupManager
  module BucketError
    class NoNameError < StandardError; end
    class NoConfig < StandardError; end
  end

  class Bucket
    attr_accessor :name
  
    def initialize(name, s3_bucket)
      @name = name
      @s3_bucket = s3_bucket
    end
  
    def self.find_all
      connect!
      AWS::S3::Service.buckets.select{|b| b.name =~ %r{^#{config["collection_prefix"]}_}}.map{|b| b.name.sub(%r{^#{config["collection_prefix"]}_},"")}
    end
  
    def self.find(id)    
      connect!
      bucket = AWS::S3::Bucket.find(expand_name(id))
      new(id, bucket)
    end
  
    def self.create!(name)
      raise BucketError::NoNameError.new if name.nil? || name.strip == ""
      connect!
      AWS::S3::Bucket.create("#{config["collection_prefix"]}_#{name}")
    end
  
    def store(filename, data)
      AWS::S3::S3Object.store(filename, data, bucket_name)
    end
  
    def retrieve(filename)
      AWS::S3::S3Object.value(filename, bucket_name)
    end
  
    def files
      @s3_bucket.objects
    end

    private
      def self.config
        YAML.load_file("/etc/s3backup-manager/config.yml")
      rescue Errno::ENOENT
        raise S3BackupManager::BucketError::NoConfig.new("No configuration file could be found at /etc/s3backup-manager/config.yml")
      end
    
      def self.expand_name(name)
        "#{config["collection_prefix"]}_#{name}"
      end
    
      def self.connect!
        AWS::S3::Base.establish_connection!(
          :access_key_id     => config["aws_access_key_id"],
          :secret_access_key => config["aws_secret_access_key"]
        )
      end

      def bucket_name
        Bucket.expand_name(name)
      end    
  end
end