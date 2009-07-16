require "#{File.dirname(__FILE__)}/../spec_helper.rb"
require "#{File.dirname(__FILE__)}/../../lib/s3backup-manager.rb"

describe Bucket do
  
  describe "when there is no configuration file" do
    it "should raise a config file missing error" do
      lambda do 
        Bucket.find_all
      end.should raise_error(S3BackupManager::BucketError::NoConfigError)
    end
  end
  
  describe "when there is a configuration file" do
    before(:each) do
      stub_aws
      AWS::S3::Service.stub!(:buckets).and_return([
        mock("bucket", :name => "backup_collection_name_bucket_1"),
        mock("bucket", :name => "backup_collection_name_bucket_2"),
        mock("bucket", :name => "backup_collection_name_bucket_3")
        ])
    end
    
    it "should connect using the credentials in the file" do
      AWS::S3::Base.should_receive(:establish_connection!).with(
        :access_key_id     => "unique_key_id",
        :secret_access_key => "sekret_keyz")
      Bucket.find_all
    end
    
    it "should it should find a bucket by name" do
      AWS::S3::Bucket.should_receive(:find).with("backup_collection_name_bucket_name")
      Bucket.find("bucket_name")
    end
    
    it "should find all buckets and strip off collection prefix" do
      Bucket.find_all.should be_include("bucket_1")
    end
    
    describe "when creating a new bucket" do
      it "should create it" do
        AWS::S3::Bucket.should_receive(:create).with(
          "backup_collection_name_new_bucket")
        Bucket.create!("new_bucket")
      end

      it "should raise an error if no name provided" do
        lambda do
          Bucket.create!("")
        end.should raise_error(S3BackupManager::BucketError::NoNameError)
      end
    end

    describe "when managing files in a bucket" do
      before(:each) do
        @bucket = Bucket.new("test_bucket")
        AWS::S3::S3Object.stub!(:store)
        AWS::S3::S3Object.stub!(:value)
      end

      it "should store the data" do
        AWS::S3::S3Object.should_receive(:store).with(
          "filename.txt","some data here", "backup_collection_name_test_bucket")
        @bucket.store("filename.txt","some data here")
      end
      
      it "should retrieve the data" do
        AWS::S3::S3Object.should_receive(:value).with(
          "filename.txt", "backup_collection_name_test_bucket").and_return(
          "some data returned")
        @bucket.retrieve("filename.txt").should == "some data returned"
      end
      
      it "should list the files in a bucket" do
        AWS::S3::Bucket.stub!(:find).with(
          "backup_collection_name_bucket_name").and_return(
          mock("bucket", :objects => ["file 1", "file 2"]))
        @bucket = Bucket.find("bucket_name")
        @bucket.files.should be_include("file 2")
      end
    end
  end

end