require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require 'rake/rdoctask'

gem_spec = Gem::Specification.new do |s|
  s.version = '0.0.2'
  s.name = "s3backup-manager"
  s.summary = "Scripts and daemon to manage encrypted backups on AmazonS3"
  s.description = "A series of scripts and a rack application for backing up databases and filesystems into tarballs, encrypting, and then storing off-site on AmazonS3"
  s.email = "glenn@rubypond.com"
  s.homepage = "http://github.com/rubypond/s3backup-manager"
  s.authors = ["Glenn Gillen"]
  s.test_files = FileList['spec/**/*']
  s.files = FileList['README.rdoc', 'Rakefile', 'lib/**/*.rb', 'bin/*', 'config/*']
  s.add_dependency('aws-s3', '>= 0.4')
  s.add_dependency('archive-tar-minitar', '>= 0.5.2')
  s.has_rdoc = 'false'
end

Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

task :default => :spec

Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "s3backup-manager #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
  t.rcov = false
  # t.rcov_dir = '../doc/output/coverage'
  # t.rcov_opts = ['--exclude', 'spec\/spec,bin\/spec,examples,\/var\/lib\/gems,\.autotest']
end
