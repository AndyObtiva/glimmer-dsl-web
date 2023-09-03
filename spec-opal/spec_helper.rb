ENV['RUBY_ENV'] = 'test'

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
  
  config.after do
    Document.ready? do
      Glimmer::SWT::WidgetProxy.reset_max_id_numbers!
      @target.dispose if @target && @target.respond_to?(:dispose)
    end
  end
end

require 'glimmer-dsl-web'
require 'fixtures/person'
require 'fixtures/contact_manager/contact_manager_presenter'
