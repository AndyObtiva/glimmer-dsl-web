require 'glimmer-dsl-web'

unless Object.const_defined?(:HelloMutation) # this is only needed in sample selector app due to file reloading, but not in real apps.
  class HelloMutation
    include Glimmer::Web::Component
    
    before_render do
      @action_buttons = []
    end
    
    after_render do
      toggle_action_buttons_disabled(true)
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
                toggle_action_buttons_disabled(true)
              else
                toggle_action_buttons_disabled(false)
              end
            end
          }
          
          @action_buttons << button('Append list item') {
            onclick do
              @list.append {
                new_li
              }
              toggle_action_buttons_disabled(true)
              @input.value = ''
              @input.focus
            end
          }
          
          @action_buttons << button('Prepend list item') {
            onclick do
              @list.prepend {
                new_li
              }
              toggle_action_buttons_disabled(true)
              @input.value = ''
              @input.focus
            end
          }
          
          @action_buttons << button('Insert list item') {
            onclick do
              index = [@insert_index_input.value.to_i, @list.children.size].min
              @list.insert_at(index) {
                new_li
              }
              toggle_action_buttons_disabled(true)
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
      
      r('.actions label[for=insert-index-input]') {
        margin_left -5
      }
      
      r('ul li') {
        height 22.5
      }
      
      r('ul li button') {
        display :none
        margin_left 5
      }
      
      r('ul li:hover button') {
        display :initial
      }
    }
  end
  
  private
  
  def new_li
    li { |current_li|
      span { @input.value }
      @action_buttons << button('Insert before') {
        onclick do
          current_li.before {
            new_li
          }
          toggle_action_buttons_disabled(true)
          @input.value = ''
          @input.focus
        end
      }
      @action_buttons << button('Insert after') {
        onclick do
          current_li.after {
            new_li
          }
          toggle_action_buttons_disabled(true)
          @input.value = ''
          @input.focus
        end
      }
    }
  end
  
  def toggle_action_buttons_disabled(disabled)
    @action_buttons.each { |action_button| action_button.disabled = disabled }
  end
end

Document.ready? do
  HelloMutation.render
end
