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
require 'lib/rubizon/version'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rubizon"
  gem.version = Rubizon::Version::STRING
  gem.homepage = "http://github.com/randymized/rubizon"
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
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_dependency 'ruby-hmac', '~> 0.4.0'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
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
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = Rubizon::Version::STRING

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rubizon #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
