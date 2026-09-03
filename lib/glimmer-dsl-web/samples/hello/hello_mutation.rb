require 'glimmer-dsl-web'

unless Object.const_defined?(:HelloMutation) # this is only needed in sample selector app due to file reloading, but not in real apps.
  class HelloMutation
    include Glimmer::Web::Component
    
    after_render do
      @append_button.disabled = @prepend_button.disabled = @insert_button.disabled = true
    end
    
    markup {
      div {
        h1('Hello, Mutation!')
        
        p {
          'Add items to a list via element DOM mutations.'
        }
        
        div(class: 'actions') {
          @input = input(placeholder: 'Enter list item content') {
            oninput do
              if @input.value.to_s.strip == ''
                @append_button.disabled = @prepend_button.disabled = @insert_button.disabled = true
              else
                @append_button.disabled = @prepend_button.disabled = @insert_button.disabled = false
              end
            end
          }
          
          @append_button = button('Append list item') {
            onclick do
              @list.append {
                li { @input.value }
              }
              @input.value = ''
              @input.focus
            end
          }
          
          @prepend_button = button('Prepend list item') {
            onclick do
              @list.prepend {
                li { @input.value }
              }
              @input.value = ''
              @input.focus
            end
          }
          
          @insert_button = button('Insert list item') {
            onclick do
              index = [@insert_index_input.value.to_i, @list.children.size].min
              @list.insert_at(index) {
                li { @input.value }
              }
              @input.value = ''
              @input.focus
            end
          }
          
          label(for: 'insert-index-input') { 'at index: ' }
          @insert_index_input = input(id: 'insert-index-input', type: 'number', value: 0, min: 0) {
            oninput do
              max_value = @list.children.size
              @insert_index_input.value = max_value if @insert_index_input.value.to_i > max_value
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
      
      r('.actions input#insert-index-input') {
        width 40
      }
    }
  end
end

Document.ready? do
  HelloMutation.render
end
