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
              reset_input_and_button_enablement
            end
          }
          
          @action_buttons << button('Prepend list item') {
            onclick do
              @list.prepend {
                new_li
              }
              reset_input_and_button_enablement
            end
          }
          
          @action_buttons << button('Insert list item') {
            onclick do
              index = [@insert_index_input.value.to_i, @list.children.size].min
              @list.insert_at(index) {
                new_li
              }
              reset_input_and_button_enablement
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
      li_span(text: @input.value)
      @action_buttons << button('Insert before') {
        onclick do
          current_li.before {
            new_li
          }
          reset_input_and_button_enablement
        end
      }
      @action_buttons << button('Insert after') {
        onclick do
          current_li.after {
            new_li
          }
          reset_input_and_button_enablement
        end
      }
    }
  end
  
  def li_span(text:)
    li_span_element = span(text) {
      ondblclick do
        make_li_editable(li_span_element)
      end
    }
  end
  
  def make_li_editable(li_span_element)
    width = li_span_element.get_bounding_client_rect.width + 20
    li_input_element = li_span_element.replace {
      li_input(value: li_span_element.inner_text)
    }
    li_input_element.focus
    li_input_element.select
  end
  
  def li_input(value:)
    li_input_element = input(type: 'text', value:) {
      onblur do
        make_li_readable(li_input_element)
      end
      onkeyup do |event|
        if event.key == 'Enter' || event.keyCode == "\r"
          make_li_readable(li_input_element)
        elsif event.key == 'Escape' || event.keyCode == 27
          make_li_readable(li_input_element, value:) # resets value
        end
      end
    }
  end
  
  def make_li_readable(li_input_element, value: nil)
    value ||= li_input_element.value
    li_input_element.replace {
      li_span(text: value)
    }
  end
  
  def reset_input_and_button_enablement
    toggle_action_buttons_disabled(true)
    @input.value = ''
    @input.focus
  end
  
  def toggle_action_buttons_disabled(disabled)
    @action_buttons.each { |action_button| action_button.disabled = disabled }
  end
end

Document.ready? do
  HelloMutation.render
end
