require_relative 'todo_input'

class NewTodoInput < TodoInput
  option :presenter
  
  markup { # evaluated against instance as a smart convention
    input(placeholder: "What needs to be done?", autofocus: "") {
      # Data-bind `input` `value` property bidirectionally to `presenter.new_todo` `task` attribute
      # meaning make any changes to the new todo task automatically update the input value
      # and any changes to the input value by the user automatically update the new todo task value
      value <=> [presenter.new_todo, :task]
    
      onkeyup do |event|
        presenter.create_todo if event.key == 'Enter' || event.keyCode == "\r"
      end
    }
  }
  
  style { # evaluated against class as a smart convention (common to all instances)
    todo_input_styles
    
    r(component_element_selector) { # NewTodoInput has component_element_class as 'new-todo-input'
      padding '16px 16px 16px 60px'
      height 65
      border :none
      background 'rgba(0, 0, 0, 0.003)'
      box_shadow 'inset 0 -2px 1px rgba(0,0,0,0.03)'
    }
    
    r("#{component_element_selector}::placeholder") {
      font_style :italic
      font_weight '400'
      color 'rgba(0, 0, 0, 0.4)'
    }
  }
end
