# frozen_string_literal: true

require_relative "lib/what_dya_return/version"

Gem::Specification.new do |spec|
  spec.name = "what_dya_return"
  spec.version = WhatDyaReturn::VERSION
  spec.authors = ["Wataru MIYAGUNI"]
  spec.email = ["gonngo@gmail.com"]

  spec.summary = "Predict Ruby code return values."
  spec.homepage = "https://github.com/gongo/what_dya_return"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "rubocop-ast", "~> 1"
end
