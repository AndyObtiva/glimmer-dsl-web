require_relative 'todo_input'

class NewTodoInput < TodoInput
  option :presenter
  
  markup {
    input(placeholder: "What needs to be done?", autofocus: "") {
      value <=> [presenter.new_todo, :task]
    
      onkeyup do |event|
        presenter.create_todo if event.key == 'Enter' || event.keyCode == "\r"
      end
    }
  }
  
  style {
    todo_input_styles
    
    r(component_element_selector) {
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
