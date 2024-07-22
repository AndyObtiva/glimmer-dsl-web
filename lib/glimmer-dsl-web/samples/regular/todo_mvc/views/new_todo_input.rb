require_relative 'todo_input'

class NewTodoInput < TodoInput
  option :presenter
  
  markup { # evaluated against instance as a smart default convention
    input(placeholder: "What needs to be done?", autofocus: "") {
      value <=> [presenter.new_todo, :task]
    
      onkeyup do |event|
        presenter.create_todo if event.key == 'Enter' || event.keyCode == "\r"
      end
    }
  }
  
  style { # evaluated against class as a smart default convention (common to all instances)
    todo_input_styles
    
    rule(".#{component_element_class}") { # built-in component_class.component_element_class (e.g. NewTodoInput has CSS class as new-todo-input)
      padding '16px 16px 16px 60px'
      height '65px'
      border 'none'
      background 'rgba(0, 0, 0, 0.003)'
      box_shadow 'inset 0 -2px 1px rgba(0,0,0,0.03)'
    }
    
    rule(".#{component_element_class}::placeholder") { # built-in component_class.component_element_class (e.g. NewTodoInput has CSS class as new-todo-input)
      font_style 'italic'
      font_weight '400'
      color 'rgba(0, 0, 0, 0.4)'
    }
  }
end
