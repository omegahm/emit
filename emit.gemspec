
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "emit/version"

Gem::Specification.new do |spec|
  spec.name          = "emit"
  spec.version       = Emit::VERSION
  spec.authors       = ["Mads Ohm Larsen"]
  spec.email         = ["mads.ohm@gmail.com"]

  spec.summary       = "CSP for Ruby"
  spec.description   = "Communicating Sequential Processes with Ruby fibers"
  spec.homepage      = "https://github.com/omegahm/emit"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.7"
end
