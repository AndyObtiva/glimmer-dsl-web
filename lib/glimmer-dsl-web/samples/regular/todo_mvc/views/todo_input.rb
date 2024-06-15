# Superclass for NewTodoInput and EditTodoInput with common styles
class TodoInput
  include Glimmer::Web::Component
  
  def todo_input_class
    'todo-input'
  end
  
  def todo_input_styles
    rule(".#{todo_input_class}") {
      position 'relative'
      margin '0'
      width '100%'
      font_size '24px'
      font_family 'inherit'
      font_weight 'inherit'
      line_height '1.4em'
      color 'inherit'
      padding '6px'
      border '1px solid #999'
      box_shadow 'inset 0 -1px 5px 0 rgba(0, 0, 0, 0.2)'
      box_sizing 'border-box'
      _webkit_font_smoothing 'antialiased'
    }
    
    rule(".#{todo_input_class}::selection") {
      background 'red'
    }
  end
end
