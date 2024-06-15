require_relative 'todo_input'

class EditTodoInput < TodoInput
  option :presenter
  option :todo
  
  markup {
    input(class: todo_input_class) { |edit_input|
      style <= [ todo, :editing,
                 on_read: ->(editing) { editing ? '' : 'display: none;' },
                 after_read: ->(_) { edit_input.focus if todo.editing? }
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
      
      style {
        todo_input_styles
      }
    }
  }
  
  def todo_input_class
    'edit-todo'
  end
  
  def todo_input_styles
    super
    
    rule("*:has(> .#{todo_input_class})") {
      position 'relative'
    }
    
    rule(".#{todo_input_class}") {
      position 'absolute'
      display 'block'
      width 'calc(100% - 43px)'
      padding '12px 16px'
      margin '0 0 0 43px'
      top '0'
    }
  end
end
