require 'glimmer-dsl-web'

require_relative 'todo_mvc/presenters/todo_presenter'

require_relative 'todo_mvc/views/new_todo_form'
require_relative 'todo_mvc/views/todo_list'
require_relative 'todo_mvc/views/todo_filters'
require_relative 'todo_mvc/views/todo_mvc_footer'

class TodoMvc
  include Glimmer::Web::Component
  
  before_render do
    @presenter = TodoPresenter.new
  end
  
  after_render do
    @presenter.setup_filter_routes
  end
  
  markup {
    div(class: 'todomvc') {
      section(class: 'todoapp') {
        new_todo_form(presenter: @presenter)
        
        todo_list(presenter: @presenter)
        
        todo_filters(presenter: @presenter)
      }
      
      todo_mvc_footer
      
      on_remove do
        @presenter.unsetup_filter_routes
      end
    }
  }
  
  style {
    r('body, button, html') {
      margin 0
      padding 0
    }
    
    r('button') {
      _webkit_font_smoothing :antialiased
      _webkit_appearance :none
      appearance :none
      background :none
      border 0
      color :inherit
      font_family :inherit
      font_size '100%'
      font_weight :inherit
      vertical_align :baseline
    }
    
    r('.todoapp') {
      background '#fff'
      margin '130px 0 40px 0'
      position :relative
      box_shadow '0 2px 4px 0 rgba(0, 0, 0, 0.2), 0 25px 50px 0 rgba(0, 0, 0, 0.1)'
    }
  
    media('screen and (-webkit-min-device-pixel-ratio:0)') {
      r('body') {
        font "14px 'Helvetica Neue', Helvetica, Arial, sans-serif"
        line_height 1.4.em
        background '#f5f5f5'
        color '#111111'
        min_width 230
        max_width 550
        margin '0 auto'
        _webkit_font_smoothing :antialiased
        font_weight '300'
      }
    }
  }
end

Document.ready? do
  TodoMvc.render
end
