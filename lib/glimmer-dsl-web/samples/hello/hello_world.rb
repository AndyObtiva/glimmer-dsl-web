require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  div {
    'Hello, World!'
  }
end
