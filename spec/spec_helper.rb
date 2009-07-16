require 'rubygems'
require 'spec'
Dir[File.join(File.dirname(__FILE__)+'/lib/*.rb')].sort.each { |lib| require lib }

include S3BackupManager
include S3BackupManager::Mocks