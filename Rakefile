# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
$: << File.join(File.dirname(__FILE__),'lib')

require 'rubizon/version'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rubizon"
  gem.homepage = "http://github.com/randymized/rubizon"
  gem.version = Rubizon::Version::STRING
  gem.license = "MIT"
  gem.summary = %Q{A Ruby interface to Amazon Web Services}
  gem.description = %Q{A Ruby interface to Amazon Web Services.  Rubizon separates creating a
properly-formed, signed URL for making an AWS request from the transport
mechanism used.

In its initial implementation, Rubizon simply builds and signs URLs.  Further
development may include adapters to various transport mechanisms and
interpretation of results.
}
  gem.email = "ot40ddj02@sneakemail.com"
  gem.authors = ["Randy McLaughlin"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = Rubizon::Version::STRING

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rubizon #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
