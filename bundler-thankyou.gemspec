require_relative 'lib/bundler/thankyou/version'

Gem::Specification.new do |spec|
  spec.name          = 'bundler-thankyou'
  spec.version       = Bundler::Thankyou::VERSION
  spec.authors       = ['Michael Bumann']
  spec.email         = ['hello@michaelbumann.com"']

  spec.summary       = %q{Lightning based donation system for rubygems}
  spec.description   = %q{A Bitcoin lightning based donation system that allows to send a "thankyou" to the gems in your Gemfile}
  spec.homepage      = 'https://michaelbumann.com'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/bumi/bundle-thankyou'

  spec.metadata['funding'] = 'lightning:038474ec195f497cf4036e5994bd820dd365bb0aaa7fb42bd9b536913a1a2dcc9e'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lightning-invoice', '~> 0.1.5'
  spec.add_runtime_dependency 'lnurl'
  spec.add_runtime_dependency 'lnrpc', '>= 0.10.0'
end
