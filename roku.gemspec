# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roku/version'

Gem::Specification.new do |gem|
  gem.name          = "roku"
  gem.version       = Roku::VERSION
  gem.authors       = ["Jon Moses"]
  gem.email         = ["jon@burningbush.us"]
  gem.description   = %q{Ruby class to easily interact with a Roku device}
  gem.summary       = %q{Control a roku device}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
