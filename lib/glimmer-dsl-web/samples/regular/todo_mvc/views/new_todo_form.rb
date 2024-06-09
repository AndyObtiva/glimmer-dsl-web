require_relative 'todo_input'

class NewTodoForm
  include Glimmer::Web::Component
  
  option :presenter
  
  markup {
    header(class: 'header') {
      h1('todos')
      
      todo_input(edit: false, placeholder: "What needs to be done?") {
        value <=> [presenter.new_todo, :task]
      
        onkeyup do |event|
          if event.key == 'Enter' || event.keyCode == "\r"
            presenter.create_todo
          end
        end
      }
      
      style {
        rule('.header h1') {
          color '#b83f45'
          font_size '80px'
          font_weight '200'
          position 'absolute'
          text_align 'center'
          _webkit_text_rendering 'optimizeLegibility'
          _moz_text_rendering 'optimizeLegibility'
          text_rendering 'optimizeLegibility'
          top '-140px'
          width '100%'
        }
      }
    }
  }
end
