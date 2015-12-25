require "codeclimate-test-reporter"

CodeClimate::TestReporter.start

require "./lib/qs"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with :rspec

  config.profile_examples = true
  config.fail_fast = true
  config.order = :rand
end
