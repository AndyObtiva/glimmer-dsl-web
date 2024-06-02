class TodoFilters
  include Glimmer::Web::Component
  
  option :presenter
  
  markup {
    footer(class: 'footer') {
      style <= [ presenter, :todos,
                 on_read: ->(todos) { todos.empty? ? 'display: none;' : '' }
               ]
      
      span(class: 'todo-count') {
        span('.strong') {
          inner_text <= [ Todo, :all,
                          on_read: ->(todos) { todos.size }
                        ]
        }
        span {
          " items left"
        }
      }
      ul(class: 'filters') {
        Todo::FILTERS.each do |filter|
          li {
            a(filter.capitalize) {
              class_name <= [ presenter, :filter,
                              on_read: -> (presenter_filter) { presenter_filter == filter ? 'selected' : '' }
                            ]
            
              onclick do |event|
                event.prevent_default
                presenter.filter = filter
              end
            }
          }
        end
      }
      
      button(class: 'clear-completed', style: 'display: block;') {
        "Clear completed"
      }
      
      style {
        rule('.footer') {
          border_top '1px solid #e6e6e6'
          font_size '15px'
          height '20px'
          padding '10px 15px'
          text_align 'center'
        }
        
        rule('.footer:before') {
          bottom '0'
          box_shadow '0 1px 1px rgba(0,0,0,.2), 0 8px 0 -3px #f6f6f6, 0 9px 1px -3px rgba(0,0,0,.2), 0 16px 0 -6px #f6f6f6, 0 17px 2px -6px rgba(0,0,0,.2)'
          content ''
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
      }
    }
  }
end
