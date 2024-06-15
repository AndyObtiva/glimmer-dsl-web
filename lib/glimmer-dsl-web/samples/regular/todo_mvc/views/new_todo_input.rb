require_relative 'todo_input'

class NewTodoInput < TodoInput
  option :presenter
  option :placeholder
  
  markup {
    input(class: todo_input_class, placeholder: placeholder, autofocus: "") {
      value <=> [presenter.new_todo, :task]
    
      onkeyup do |event|
        presenter.create_todo if event.key == 'Enter' || event.keyCode == "\r"
      end
    
      style {
        todo_input_styles
      }
    }
  }
  
  def todo_input_class
    'new-todo'
  end
  
  def todo_input_styles
    super
    
    rule(".#{todo_input_class}") {
      padding '16px 16px 16px 60px'
      height '65px'
      border 'none'
      background 'rgba(0, 0, 0, 0.003)'
      box_shadow 'inset 0 -2px 1px rgba(0,0,0,0.03)'
    }
    
    rule(".#{todo_input_class}::placeholder") {
      font_style 'italic'
      font_weight '400'
      color 'rgba(0, 0, 0, 0.4)'
    }
  end
end
