# -*- encoding: utf-8 -*-
require File.expand_path('../lib/autotest-email/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alex Klimenkov"]
  gem.email         = ["alex.klimenkov89@gmail.com"]
  gem.description   = %q{Provide Email for autotest}
  gem.summary       = %q{Send, get email for autotest}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "autotest-email"
  gem.require_paths = ["lib"]
  gem.version       = Autotest::Email::VERSION

  gem.add_dependency 'mail'
end
