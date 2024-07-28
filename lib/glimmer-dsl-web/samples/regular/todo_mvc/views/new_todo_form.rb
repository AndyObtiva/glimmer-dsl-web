require_relative 'new_todo_input'

class NewTodoForm
  include Glimmer::Web::Component
  
  option :presenter
  
  markup {
    header(class: 'header') {
      h1('todos')
      
      new_todo_input(presenter: presenter)
    }
  }
  
  style {
    r('.header h1') {
      color '#b83f45'
      font_size 80
      font_weight '200'
      position :absolute
      text_align :center
      _webkit_text_rendering :optimizeLegibility
      _moz_text_rendering :optimizeLegibility
      text_rendering :optimizeLegibility
      top -140
      width '100%'
    }
  }
end
