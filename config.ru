require 'opal/rspec'
require 'opal-async'
require 'opal-jquery'

Opal.use_gem 'glimmer-dsl-web'

# or use Opal::RSpec::SprocketsEnvironment.new(spec_pattern='spec-opal/**/*_spec.{rb,opal}') to customize the pattern
sprockets_env = Opal::RSpec::SprocketsEnvironment.new
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  sprockets_env.add_spec_paths_to_sprockets
  
  # Enable this line to filter by a particular spec or specs
#   sprockets_env.spec_pattern = '**/*/table_spec.rb'

  s.debug = false
}
