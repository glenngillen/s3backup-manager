#!/usr/bin/env ruby
require 'optparse'
require 'rubygems'
require 's3backup-manager'

options = {}
optparse = OptionParser.new do|opts|
  opts.banner = "Usage: s3restore.rb [options] backup_file destination"
  
  options[:adapter] = "postgres"
  opts.on('--adapter ADAPTER', 'Type of database to backup. To be used with "--type database"' ) do |a|
    unless ["mysql","postgres"].include?(t)
      puts 'Only "mysql" and "postgres" are valid values for --adapter'
      exit(1)
    end
    options[:adapter] = a
  end
  
  opts.on('--bucket BUCKET', 'AmazonS3 bucket you wish to store the backup in' ) do |b|
    options[:bucket] = b
  end
  
  opts.on('--timestamp TIMESTAMP', 'Timestamp of file/database you want to restore' ) do |t|
    options[:timestamp] = t
  end
  
  options[:type] = "file"
  opts.on('--type TYPE', String, 'Type of backup. Valid options are "file" and "database". Defaults to "file"' ) do |t|
    unless ["file","database"].include?(t.downcase)
      puts 'Only "file" and "database" are valid values for --type'
      exit(1)
    end
    options[:type] = t.downcase
    options[:type_provided] = true
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
  
  opts.on('-l', '--list', 'List all available buckets, or backed up files/databases if provided with --type') do
    options[:list] = true
  end
  
end
optparse.parse!

if options[:list] && !options[:type_provided]
  S3BackupManager::Bucket.find_all.each do |bucket|
    puts bucket
  end
  exit
end

def setup_backup_adapter(options)
  if options[:bucket]
    eval("S3BackupManager::#{options[:type].capitalize}Backup").new(options)
  else
    puts "You need to specify a valid bucket for retrieval"
    exit(1) 
  end  
end

backup_adapter = setup_backup_adapter(options)

if options[:list] && options[:bucket]
  backup_adapter.files.each do |file|
    puts file.key.sub(%r{^filesystem/},"")
  end
  exit
end

if ARGV.size != 2
  puts "Please specify the source and destination files"
  exit(1)
end

source = ARGV[0]
destination = ARGV[1]
puts "Restoring #{source}..."
backup_adapter.restore(source, options[:timestamp], destination)