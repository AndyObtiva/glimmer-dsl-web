require_relative 'edit_todo_input'

class TodoListItem
  include Glimmer::Web::Component
  
  option :presenter
  option :todo
  
  after_render do
    # after rendering markup, observe todo deleted attribute and remove component when deleted
    observe(todo, :deleted) do |deleted|
      self.remove if deleted
    end
  end
  
  markup {
    li {
      # Data-bind inclusion of `completed` in `li` `class` attribute unidirectionally to `todo` `completed` attribute,
      # meaning inclusion/exclusion of `completed` class happens automatically when `todo.completed` boolean value changes.
      class_name(:completed) <= [todo, :completed]
      
      # Data-bind inclusion of `active` in `li` `class` attribute unidirectionally to `todo` `completed` attribute, negated,
      # meaning inclusion/exclusion of `active` class happens automatically when `todo.completed` negated boolean value changes.
      class_name(:active) <= [todo, :completed, on_read: :!]
      
      # Data-bind inclusion of `editing` in `li` `class` attribute unidirectionally to `todo` `editing` attribute,
      # meaning inclusion/exclusion of `editing` class happens automatically when `todo.editing` boolean value changes.
      class_name(:editing) <= [todo, :editing]
      
      div(class: 'view') {
        input(class: 'toggle', type: 'checkbox') {
          # Data-bind `input` `checked` property bidirectionally to `todo` `completed` attribute
          # meaning make any changes to the `todo` `completed` attribute value automatically update the `input` `checked` property
          # and any changes to the `input` `checked` property by the user automatically update the `todo` `completed` attribute value.
          # `after_write` hook is invoked after writing a new value to the model attribute (`todo` `completed` attribute)
          checked <=> [todo, :completed]
        }
        
        label {
          # Data-bind `label` inner HTML unidirectionally to `todo.task` (`String` value),
          # meaning make changes to `todo` `task` attribute automatically update `label` inner HTML.
          inner_html <= [todo, :task]
          
          ondblclick do |event|
            # if the markup root (li) last child is not an input field, re-open content and add an edit input field
            unless markup_root.children.last.keyword == 'input'
              markup_root.content {
                edit_todo_input(presenter:, todo:)
              }
            end
            todo.start_editing
          end
        }
        
        button(class: 'destroy') {
          onclick do |event|
            presenter.destroy(todo)
          end
        }
      }
    }
  }
  
  style {
    r('.todo-list li.completed label') {
      color '#949494'
      text_decoration 'line-through'
    }
    
    r('.todo-list li') {
      border_bottom '1px solid #ededed'
      font_size 24
      position :relative
    }
    
    r('.todo-list li .toggle') {
      _webkit_appearance :none
      appearance :none
      border :none
      bottom 0
      height :auto
      margin 'auto 0'
      opacity 0
      position :absolute
      text_align :center
      top 0
      width 40
    }
    
    r('.todo-list li label') {
      color '#484848'
      display :block
      font_weight '400'
      line_height '1.2'
      min_height 40
      padding '15px 15px 15px 60px'
      transition 'color .4s'
      word_break 'break-all'
    }
    
    r('.todo-list li .toggle+label') {
      background_image 'url(data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A//www.w3.org/2000/svg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%23949494%22%20stroke-width%3D%223%22/%3E%3C/svg%3E)'
      background_position 0
      background_repeat 'no-repeat'
    }
    
    r('.todo-list li.completed label') {
      color '#949494'
      text_decoration 'line-through'
    }
    
    r('.todo-list li .toggle:checked+label') {
      background_image 'url(data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%2359A193%22%20stroke-width%3D%223%22%2F%3E%3Cpath%20fill%3D%22%233EA390%22%20d%3D%22M72%2025L42%2071%2027%2056l-4%204%2020%2020%2034-52z%22%2F%3E%3C%2Fsvg%3E)'
    }
    
    r('.todo-list li.editing') {
      border_bottom :none
      padding 0
    }
    
    r('.todo-list li.editing input[type=checkbox], .todo-list li.editing label') {
      opacity 0
    }
    
    r('.todo-list li .destroy') {
      bottom 0
      color '#949494'
      display :none
      font_size 30
      height 40
      margin 'auto 0'
      position :absolute
      right 10
      top 0
      transition 'color .2s ease-out'
      width 40
    }
    
    r('.todo-list li:focus .destroy, .todo-list li:hover .destroy') {
      display :block
    }
    
    r('.todo-list li .destroy:focus, .todo-list li .destroy:hover') {
      color '#c18585'
    }
    
    r('.todo-list li .destroy:after') {
      content '"×"'
      display :block
      height 100.%
      line_height '1.1'
    }
    
    media ('screen and (-webkit-min-device-pixel-ratio: 0)') {
      r('.todo-list li .toggle, .toggle-all') {
        background :none
      }
      
      r('.todo-list li .toggle') {
        height 40
      }
    }
  }
end
            
