require 'glimmer-dsl-web'

unless Object.const_defined?(:HelloMutation) # this is only needed in sample selector app due to file reloading, but not in real apps.
  class HelloMutation
    include Glimmer::Web::Component
    
    markup {
      div {
        h1('Hello, Mutation!')
        
        p {
          'Add items to a list via element DOM mutations.'
        }
        
        div(class: 'actions') {
          @input = input(placeholder: 'Enter list item content')
          
          button('Append list item') {
            onclick do
              @list.append {
                li { @input.value }
              }
              @input.value = ''
              @input.focus
            end
          }
          
          button('Prepend list item') {
            onclick do
              @list.prepend {
                li { @input.value }
              }
              @input.value = ''
              @input.focus
            end
          }
        }
        
        @list = ul
      }
    }
    
    style {
      r('.actions input, .actions button') {
        margin '10px 10px 10px 0'
      }
    }
  end
end

Document.ready? do
  HelloMutation.render
end
