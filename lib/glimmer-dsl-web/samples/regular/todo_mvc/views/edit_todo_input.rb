require_relative 'todo_input'

class EditTodoInput < TodoInput
  option :presenter
  option :todo
  
  markup { # evaluated against instance as a smart default convention
    input { |edit_input|
      # Data-bind inclusion of `li` `class` `editing` unidirectionally to todo editing attribute,
      # meaning inclusion of editing class is determined by todo editing boolean attribute.
      # `after_read` hook will have `input` grab keyboard focus when editing todo.
      class_name(:editing) <= [ todo, :editing,
                                after_read: -> { edit_input.focus if todo.editing? }
                              ]
    
      # Data-bind `input` `value` property bidirectionally to `todo` `task` attribute
      # meaning make any changes to the `todo` `task` attribute value automatically update the `input` `value` property
      # and any changes to the `input` `value` property by the user automatically update the `todo` `task` attribute value.
      value <=> [todo, :task]
      
      onkeyup do |event|
        if event.key == 'Enter' || event.keyCode == "\r"
          todo.save_editing
          presenter.destroy(todo) if todo.task.strip.empty?
        elsif event.key == 'Escape' || event.keyCode == 27
          todo.cancel_editing
        end
      end
      
      onblur do |event|
        todo.save_editing
      end
    }
  }
    
  style { # evaluated against class as a smart default convention (common to all instances)
    todo_input_styles
    
    r("*:has(> #{component_element_selector})") {
      position :relative
    }
    
    r(component_element_selector) {
      position :absolute
      display :none
      width 'calc(100% - 43px)'
      padding '12px 16px'
      margin '0 0 0 43px'
      top 0
    }
    
    r("#{component_element_selector}.editing") {
      display :block
    }
  }
end
