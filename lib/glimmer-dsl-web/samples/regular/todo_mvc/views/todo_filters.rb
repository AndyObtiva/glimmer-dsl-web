class TodoFilters
  include Glimmer::Web::Component
  
  option :presenter
  
  markup {
    footer {
      # Data-bind `footer` `style` `display` unidirectionally to presenter todos,
      # and on read, convert todos based on whether they are empty to 'none' or 'block'
      style(:display) <= [ presenter, :todos,
                           on_read: ->(todos) { todos.empty? ? 'none' : 'block' }
                         ]
      
      span(class: 'todo-count') {
        span('.strong') {
          # Data-bind `span` `inner_text` unidirectionally to presenter active_todo_count
          inner_text <= [presenter, :active_todo_count]
        }
        span {
          # Data-bind `span` `inner_text` unidirectionally to presenter active_todo_count,
          # and on read, convert active_todo_count to string that follows count number
          inner_text <= [presenter, :active_todo_count,
                          on_read: -> (active_todo_count) { " item#{'s' if active_todo_count != 1} left" }
                        ]
        }
      }
      
      ul(class: 'filters') {
        TodoPresenter::FILTERS.each do |filter|
          li {
            a(filter.to_s.capitalize, href: "#/#{filter unless filter == :all}") {
              # Data-bind inclusion of `a` `class` `selected` unidirectionally to presenter filter attribute,
              # and on read of presenter filter, convert to boolean value of whether selected class is included
              class_name(:selected) <= [ presenter, :filter,
                                          on_read: -> (presenter_filter) { presenter_filter == filter }
                                       ]
            
              onclick do |event|
                presenter.filter = filter
              end
            }
          }
        end
      }
      
      button('Clear completed', class: 'clear-completed') {
        # Data-bind inclusion of `button` `class` `can-clear-completed` unidirectionally to presenter can_clear_completed attribute,
        # meaning inclusion of can-clear-completed class is determined by presenter can_clear_completed boolean attribute.
        class_name('can-clear-completed') <= [presenter, :can_clear_completed]
      
        onclick do |event|
          presenter.clear_completed
        end
      }
    }
  }
  
  style {
    r(component_element_selector) {
      border_top '1px solid #e6e6e6'
      font_size 15
      height 20
      padding '10px 15px'
      text_align :center
      display :none
    }
    
    r("#{component_element_selector}:before") {
      bottom 0
      box_shadow '0 1px 1px rgba(0,0,0,.2), 0 8px 0 -3px #f6f6f6, 0 9px 1px -3px rgba(0,0,0,.2), 0 16px 0 -6px #f6f6f6, 0 17px 2px -6px rgba(0,0,0,.2)'
      content '""'
      height 50
      left 0
      overflow :hidden
      position :absolute
      right 0
    }
    
    r('.todo-count') {
      float :left
      text_align :left
    }
    
    r('.todo-count .strong') {
      font_weight '300'
    }
    
    r('.filters') {
      left 0
      list_style :none
      margin 0
      padding 0
      position :absolute
      right 0
    }
    
    r('.filters li') {
      display :inline
    }
    
    r('.filters li a') {
      border '1px solid transparent'
      border_radius 3
      color :inherit
      margin 3
      padding '3px 7px'
      text_decoration :none
      cursor :pointer
    }
    
    r('.filters li a.selected') {
      border_color '#ce4646'
    }
    
    r('.clear-completed, html .clear-completed:active') {
      cursor :pointer
      float :right
      line_height 19
      position :relative
      text_decoration :none
      display :none
    }
    
    r('.clear-completed.can-clear-completed, html .clear-completed.can-clear-completed:active') {
      display :block
    }
    
    media('(max-width: 430px)') {
      r(component_element_selector) {
        height 50
      }
      
      r('.filters') {
        bottom 10
      }
    }
  }
end
