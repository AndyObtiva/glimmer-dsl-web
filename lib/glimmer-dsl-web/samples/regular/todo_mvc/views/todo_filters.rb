class TodoFilters
  include Glimmer::Web::Component
  
  option :presenter
  
  markup {
    footer(class: 'todo-filters') {
      style <= [ presenter, :todos,
                 on_read: ->(todos) { todos.empty? ? 'display: none;' : '' }
               ]
      
      span(class: 'todo-count') {
        span('.strong') {
          inner_text <= [presenter, :active_todo_count]
        }
        span {
          inner_text <= [presenter, :active_todo_count,
                          on_read: -> (active_todo_count) { " item#{'s' if active_todo_count != 1} left" }
                        ]
        }
      }
      
      ul(class: 'filters') {
        TodoPresenter::FILTERS.each do |filter|
          li {
            a(filter.to_s.capitalize, href: "#/#{filter unless filter == :all}") {
              class_name <= [ presenter, :filter,
                              on_read: -> (presenter_filter) { presenter_filter == filter ? 'selected' : '' }
                            ]
            
              onclick do |event|
                presenter.filter = filter
              end
            }
          }
        end
      }
      
      button('Clear completed', class: 'clear-completed') {
        style <= [ presenter, :can_clear_completed,
                   on_read: -> (can_clear_completed) { can_clear_completed ? '' : 'display: none;' },
                 ]
      
        onclick do |event|
          presenter.clear_completed
        end
      }
      
      style {
        rule('.todo-filters') {
          border_top '1px solid #e6e6e6'
          font_size '15px'
          height '20px'
          padding '10px 15px'
          text_align 'center'
        }
        
        rule('.todo-filters:before') {
          bottom '0'
          box_shadow '0 1px 1px rgba(0,0,0,.2), 0 8px 0 -3px #f6f6f6, 0 9px 1px -3px rgba(0,0,0,.2), 0 16px 0 -6px #f6f6f6, 0 17px 2px -6px rgba(0,0,0,.2)'
          content '""'
          height '50px'
          left '0'
          overflow 'hidden'
          position 'absolute'
          right '0'
        }
        
        rule('.todo-count') {
          float 'left'
          text_align 'left'
        }
        
        rule('.todo-count .strong') {
          font_weight '300'
        }
        
        rule('.filters') {
          left '0'
          list_style 'none'
          margin '0'
          padding '0'
          position 'absolute'
          right '0'
        }
        
        rule('.filters li') {
          display 'inline'
        }
        
        rule('.filters li a') {
          border '1px solid transparent'
          border_radius '3px'
          color 'inherit'
          margin '3px'
          padding '3px 7px'
          text_decoration 'none'
          cursor 'pointer'
        }
        
        rule('.filters li a.selected') {
          border_color '#ce4646'
        }
        
        rule('.clear-completed, html .clear-completed:active') {
          cursor 'pointer'
          float 'right'
          line_height '19px'
          position 'relative'
          text_decoration 'none'
        }
        
        media('(max-width: 430px)') {
          rule('.todo-filters') {
            height '50px'
          }
          
          rule('.filters') {
            bottom '10px'
          }
        }
      }
    }
  }
end
