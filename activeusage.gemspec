# frozen_string_literal: true

require_relative "lib/active_usage/version"

Gem::Specification.new do |spec|
  spec.name = "activeusage"
  spec.version = ActiveUsage::VERSION
  spec.authors = ["Tomasz Kowalewski"]
  spec.email = ["me@tkowalewski.pl"]

  spec.summary = "Cost observability core for Ruby and Rails workloads."
  spec.description = "ActiveUsage turns runtime signals into practical cost estimates for requests, jobs, and tasks."
  spec.homepage = "https://activeusage.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ActiveUsage/activeusage/tree/#{ActiveUsage::VERSION}"
  spec.metadata["changelog_uri"] = "https://github.com/ActiveUsage/activeusage/tree/#{ActiveUsage::VERSION}/CHANGELOG.md"

  spec.files = Dir["CHANGELOG.md", "LICENSE.txt", "README.md", "lib/**/*"]
  spec.require_path = "lib"
end
