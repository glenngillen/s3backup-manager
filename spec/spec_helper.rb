require 'rubygems'
require 'spec'
require "#{File.dirname(__FILE__)}/../lib/s3backup-manager.rb"
Dir[File.join(File.dirname(__FILE__)+'/lib/*.rb')].sort.each { |lib| require lib }

include S3BackupManager
include S3BackupManager::Mocks