require_relative 'todo_input'

class EditTodoInput < TodoInput
  option :presenter
  option :todo
  
  markup { # evaluated against instance as a smart default convention
    input { |edit_input|
      style <= [ todo, :editing,
                 on_read: ->(editing) { editing ? '' : 'display: none;' },
                 after_read: -> { edit_input.focus if todo.editing? }
               ]
    
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
      display :block
      width 'calc(100% - 43px)'
      padding '12px 16px'
      margin '0 0 0 43px'
      top 0
    }
  }
end
