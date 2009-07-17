Gem::Specification.new do |s|
  s.version = '0.0.3'
  s.name = "s3backup-manager"
  s.summary = "Scripts and daemon to manage encrypted backups on AmazonS3"
  s.description = "A series of scripts and a rack application for backing up databases and filesystems into tarballs, encrypting, and then storing off-site on AmazonS3"
  s.email = "glenn@rubypond.com"
  s.homepage = "http://github.com/rubypond/s3backup-manager"
  s.authors = ["Glenn Gillen"]
  s.test_files = Dir['spec/**/*']
  s.files = Dir['README.rdoc', 'Rakefile', 'lib/**/*.rb', 'bin/*', 'config/*']
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

