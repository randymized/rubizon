# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rubizon}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Randy McLaughlin"]
  s.date = %q{2011-01-03}
  s.description = %q{A Ruby interface to Amazon Web Services.  Rubizon separates creating a
properly-formed, signed URL for making an AWS request from the transport
mechanism used.

In its initial implementation, Rubizon simply builds and signs URLs.  Further
development may include adapters to various transport mechanisms and
interpretation of results.
}
  s.email = %q{ot40ddj02@sneakemail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/rubizon.rb",
    "lib/rubizon/abstract_sig2_product.rb",
    "lib/rubizon/exceptions.rb",
    "lib/rubizon/product/product_advertising.rb",
    "lib/rubizon/product/sns.rb",
    "lib/rubizon/request.rb",
    "lib/rubizon/security_credentials.rb",
    "rubizon.gemspec",
    "test/helper.rb",
    "test/test_abstract_sig2_product.rb",
    "test/test_request.rb",
    "test/test_security_credentials.rb",
    "test/test_signature_sample.rb",
    "test/test_sns.rb"
  ]
  s.homepage = %q{http://github.com/randymized/rubizon}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A Ruby interface to Amazon Web Services}
  s.test_files = [
    "test/helper.rb",
    "test/test_abstract_sig2_product.rb",
    "test/test_request.rb",
    "test/test_security_credentials.rb",
    "test/test_signature_sample.rb",
    "test/test_sns.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ruby-hmac>, ["~> 0.4.0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-hmac>, ["~> 0.4.0"])
    else
      s.add_dependency(%q<ruby-hmac>, ["~> 0.4.0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<ruby-hmac>, ["~> 0.4.0"])
    end
  else
    s.add_dependency(%q<ruby-hmac>, ["~> 0.4.0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<ruby-hmac>, ["~> 0.4.0"])
  end
end

