class TodoInput
  include Glimmer::Web::Component
  
  option :edit
  option :placeholder
  
  before_render do
    @input_class = edit ? 'edit' : 'new-todo'
  end
  
  markup {
    input(class: @input_class, placeholder: placeholder, autofocus: "") {
      style {
        todo_input_styles
      }
    }
  }
  
  def todo_input_styles
    rule('.new-todo, .edit') {
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
    
    rule('.new-todo::selection, .edit::selection') {
      background 'red'
    }
    
    rule('.new-todo') {
      padding '16px 16px 16px 60px'
      height '65px'
      border 'none'
      background 'rgba(0, 0, 0, 0.003)'
      box_shadow 'inset 0 -2px 1px rgba(0,0,0,0.03)'
    }
  end
end
