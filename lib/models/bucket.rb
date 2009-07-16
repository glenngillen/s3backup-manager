module S3BackupManager
  module BucketError
    class NoNameError < StandardError; end
    class NoConfigError < StandardError; end
    class NoBucketFoundError < StandardError; end
  end

  class Bucket
    attr_accessor :name
    attr_accessor :s3_bucket
  
    def initialize(name)
      @name = name
    end
  
    def self.find_all
      connect!
      AWS::S3::Service.buckets.select{|b| b.name =~ %r{^#{config["collection_prefix"]}_}}.map{|b| b.name.sub(%r{^#{config["collection_prefix"]}_},"")}
    end
  
    def self.find(id)    
      connect!
      bucket = AWS::S3::Bucket.find(expand_name(id))
      initialize_with_bucket(id, bucket)
    rescue AWS::S3::CurrentBucketNotSpecified
      raise BucketError::NoNameError
    rescue AWS::S3::NoSuchBucket
      raise BucketError::NoBucketFoundError
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
      def self.initialize_with_bucket(name, bucket)
        this_bucket = new(name)
        this_bucket.s3_bucket = bucket
        this_bucket
      end
      
      def self.config
        YAML.load_file("/etc/s3backup-manager/config.yml")
      rescue Errno::ENOENT
        raise S3BackupManager::BucketError::NoConfigError.new(
          "No configuration file could be found at /etc/s3backup-manager/config.yml")
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