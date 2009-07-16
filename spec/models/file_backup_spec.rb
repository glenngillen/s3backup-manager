require "#{File.dirname(__FILE__)}/../spec_helper.rb"
require "#{File.dirname(__FILE__)}/../../lib/s3backup-manager.rb"

describe FileBackup do
  before(:each) do
    mock_bucket
    mock_backup_files
    @file_backup = FileBackup.new(:bucket => "test_bucket")
  end
  
  it "should return just filesystem files" do    
    @file_backup.files.detect{|f| f.key =~ /filename1/}.should be
    @file_backup.files.detect{|f| f.key =~ /filename2/}.should be
  end
  
  it "should pack the file/directory into a tarball" do
    pending
  end
  
  it "should encrypt the data" do
    pending
  end
  
  it "should decrypt the data" do
    pending
  end
  
  it "should unpack the tarball into a file/directory" do
    pending
  end
  
  it "should backup store the packed & encrypted file in the bucket" do
    pending
  end
  
  it "should restore the file/directory" do
    pending
  end
  
  it "should cleanup any temporary files" do
    pending
  end
  
  it "should timestamp the backups" do
    pending
  end
  
  it "should encrypt using the configured secret" do
    pending
  end
  
  it "should encrypt using the current day as an initialization vector" do
    pending
  end
  
  it "should decrypt using the configured secret" do
    pending
  end
  
  it "should decrypt using the backup day as an initialization vector" do
    pending
  end
  
end
