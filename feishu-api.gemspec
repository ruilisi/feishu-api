# frozen_string_literal: true

require_relative 'lib/feishu-api/version'

Gem::Specification.new do |spec|
  spec.name = 'feishu-api'
  spec.version = FeishuApi::VERSION
  spec.authors = ['msk']
  spec.email = ['msk1143667241@outlook.com']

  spec.summary = 'feishu open api'
  spec.description = "FeishuApi is a integration of commonly used feishu open platform's APIs, easy to call."
  spec.homepage = 'https://github.com/ruilisi/feishu-api'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['rubygems_mfa_required'] = 'false'
  spec.metadata['homepage_uri'] = 'https://github.com/ruilisi/feishu-api'
  spec.metadata['source_code_uri'] = 'https://github.com/ruilisi/feishu-api.git'
  spec.metadata['changelog_uri'] = 'https://github.com/ruilisi/feishu-api/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(__dir__) do
  #   `git ls-files -z`.split("\x0").reject do |f|
  #     (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
  #   end
  # end
  spec.files = Dir['{lib}/**/*', 'LICENSE.tex', 'Rakefile', 'README.md']

  # spec.bindir = "exe"
  # spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_development_dependency 'httparty'
end
