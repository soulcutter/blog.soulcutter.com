$:.unshift File.expand_path("#{__dir__}/../lib")
require "site_builder"

# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # This option will default to `:apply_to_host_groups` in RSpec 4
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4.
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # This will default to `true` in RSpec 4
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.example_status_persistence_file_path = "spec/examples.txt"

  config.order = :random
  Kernel.srand config.seed

  # it's useful to allow more verbose output for individual spec file
  config.default_formatter = "doc" if config.files_to_run.one?

  # Print the 10 slowest examples to help identify slow tests
  config.profile_examples = 10

  config.warnings = true
end
