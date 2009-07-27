Gem::Specification.new do |s|
  s.version = '0.1.3'
  s.name = "s3backup-manager"
  s.files = ["README.rdoc", "Rakefile", "lib/adapters/mysql_adapter.rb", "lib/adapters/postgres_adapter.rb", "lib/controllers/backup_manager.rb", "lib/models/bucket.rb", "lib/models/database_backup.rb", "lib/models/file_backup.rb", "lib/models/schedule.rb", "lib/s3backup-manager.rb", "bin/s3backup", "bin/s3backup_monitor", "bin/s3restore", "config/config.yml", "config/schedule.yml", "spec/adapters", "spec/adapters/couchdb_adapter_spec.rb", "spec/adapters/mysql_adapter_spec.rb", "spec/adapters/postgres_adapter_spec.rb", "spec/fixtures", "spec/fixtures/test_backup_file.txt", "spec/lib", "spec/lib/mocks.rb", "spec/models", "spec/models/bucket_spec.rb", "spec/models/database_backup_spec.rb", "spec/models/file_backup_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.summary = "Scripts and daemon to manage encrypted backups on AmazonS3"
  s.description = "A series of scripts and a rack application for backing up databases and filesystems into tarballs, encrypting, and then storing off-site on AmazonS3"
  s.email = "glenn@rubypond.com"
  s.homepage = "http://github.com/rubypond/s3backup-manager"
  s.authors = ["Glenn Gillen"]
  s.test_files = ["spec/adapters", "spec/adapters/couchdb_adapter_spec.rb", "spec/adapters/mysql_adapter_spec.rb", "spec/adapters/postgres_adapter_spec.rb", "spec/fixtures", "spec/fixtures/test_backup_file.txt", "spec/lib", "spec/lib/mocks.rb", "spec/models", "spec/models/bucket_spec.rb", "spec/models/database_backup_spec.rb", "spec/models/file_backup_spec.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.bindir = 'bin'
  s.require_paths = [".", "lib"]
  s.executables = ["s3backup", "s3backup_monitor", "s3restore"]
  s.has_rdoc = 'false'
  
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
  
    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency('aws-s3', '>= 0.4')
      s.add_runtime_dependency('archive-tar-minitar', '>= 0.5.2')
    else
      s.add_dependency('aws-s3', '>= 0.4')
      s.add_dependency('archive-tar-minitar', '>= 0.5.2')
    end
  else
    s.add_dependency('aws-s3', '>= 0.4')
    s.add_dependency('archive-tar-minitar', '>= 0.5.2')
  end
end

