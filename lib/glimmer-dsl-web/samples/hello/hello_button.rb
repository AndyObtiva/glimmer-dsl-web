require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  div {
    button('Greet') {
      onclick do
        $$.alert('Hello, Button!')
      end
    }
  }
end
