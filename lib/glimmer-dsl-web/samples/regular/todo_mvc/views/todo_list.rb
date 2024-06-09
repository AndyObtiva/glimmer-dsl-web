class TodoList
  include Glimmer::Web::Component
  
  option :presenter
  
  markup {
    main(class: 'main') {
      style <= [ Todo, :all,
                 on_read: ->(todos) { todos.empty? ? 'display: none;' : '' }
               ]
      
      div(class: 'toggle-all-container') {
        input(class: 'toggle-all', type: 'checkbox')
        
        label('Mark all as complete', class: 'toggle-all-label', for: 'toggle-all') {
          onclick do |event|
            presenter.toggle_all_completed
          end
        }
      }
      
      ul(class: 'todo-list') {
        content(presenter, :todos) {
          presenter.todos.each do |todo|
            li {
              class_name <= [ todo, :completed,
                              on_read: -> (completed) { li_class_name(todo) }
                            ]
              class_name <= [ todo, :editing,
                              on_read: -> (editing) { li_class_name(todo) }
                            ]
              
              div(class: 'view') {
                input(class: 'toggle', type: 'checkbox') {
                  checked <=> [todo, :completed]
                }
                
                label {
                  inner_html <= [todo, :task]
                  
                  ondblclick do |event|
                    todo.start_editing
                  end
                }
                
                button(class: 'destroy') {
                  onclick do |event|
                    presenter.destroy(todo)
                  end
                }
              }
              
              edit_input = input(class: 'edit') {
                style <= [ todo, :editing,
                           on_read: ->(editing) { editing ? '' : 'display: none;' },
                           after_read: ->(_) { edit_input.focus if todo.editing? }
                         ]
              
                value <=> [todo, :task]
                
                onkeyup do |event|
                  if event.key == 'Enter' || event.keyCode == "\r"
                    todo.save_editing
                  elsif event.key == 'Escape' || event.keyCode == 27
                    todo.cancel_editing
                  end
                end
                
                onblur do |event|
                  todo.save_editing
                end
              }
            }
          end
        }
      }
      
      style {
        rule('.main') {
          border_top '1px solid #e6e6e6'
          position 'relative'
          z_index '2'
        }
        
        rule('.toggle-all') {
          border 'none'
          bottom '100%'
          height '1px'
          opacity '0'
          position 'absolute'
          right '100%'
          width '1px'
        }
              
        rule('.toggle-all+label') {
          align_items 'center'
          display 'flex'
          font_size '0'
          height '65px'
          justify_content 'center'
          left '0'
          position 'absolute'
          top '-65px'
          width '45px'
        }
        
        rule('.toggle-all+label:before') {
          color '#949494'
          content '"❯"'
          display 'inline-block'
          font_size '22px'
          padding '10px 27px'
          _webkit_transform 'rotate(90deg)'
          transform 'rotate(90deg)'
        }
        
        rule('.todo-list li.completed label') {
          color '#949494'
          text_decoration 'line-through'
        }
        
        rule('.toggle-all:focus+label, .toggle:focus+label, :focus') {
          box_shadow '0 0 2px 2px #cf7d7d'
          outline '0'
        }
        
        rule('.todo-list') {
          list_style 'none'
          margin '0'
          padding '0'
        }
        
        rule('.todo-list li') {
          border_bottom '1px solid #ededed'
          font_size '24px'
          position 'relative'
        }
        
        rule('.todo-list li .toggle') {
          _webkit_appearance 'none'
          appearance 'none'
          border 'none'
          bottom '0'
          height 'auto'
          margin 'auto 0'
          opacity '0'
          position 'absolute'
          text_align 'center'
          top '0'
          width '40px'
        }
        
        rule('.todo-list li label') {
          color '#484848'
          display 'block'
          font_weight '400'
          line_height '1.2'
          padding '15px 15px 15px 60px'
          transition 'color .4s'
          word_break 'break-all'
        }
        
        rule('.todo-list li .toggle+label') {
          background_image 'url(data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A//www.w3.org/2000/svg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%23949494%22%20stroke-width%3D%223%22/%3E%3C/svg%3E)'
          background_position '0'
          background_repeat 'no-repeat'
        }
        
        rule('.todo-list li.completed label') {
          color '#949494'
          text_decoration 'line-through'
        }
        
        rule('.todo-list li .toggle:checked+label') {
          background_image 'url(data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2240%22%20height%3D%2240%22%20viewBox%3D%22-10%20-18%20100%20135%22%3E%3Ccircle%20cx%3D%2250%22%20cy%3D%2250%22%20r%3D%2250%22%20fill%3D%22none%22%20stroke%3D%22%2359A193%22%20stroke-width%3D%223%22%2F%3E%3Cpath%20fill%3D%22%233EA390%22%20d%3D%22M72%2025L42%2071%2027%2056l-4%204%2020%2020%2034-52z%22%2F%3E%3C%2Fsvg%3E)'
        }
        
        rule('.todo-list li.editing') {
          border_bottom 'none'
          padding '0'
        }
        
        rule('.todo-list li.editing input[type=checkbox], .todo-list li.editing label') {
          opacity '0'
        }
        
        rule('button') {
          _webkit_font_smoothing 'antialiased'
          _webkit_appearance 'none'
          appearance 'none'
          background 'none'
          border '0'
          color 'inherit'
          font_family 'inherit'
          font_size '100%'
          font_weight 'inherit'
          vertical_align 'baseline'
        }
        
        rule('.todo-list li .destroy') {
          bottom '0'
          color '#949494'
          display 'none'
          font_size '30px'
          height '40px'
          margin 'auto 0'
          position 'absolute'
          right '10px'
          top '0'
          transition 'color .2s ease-out'
          width '40px'
        }
        
        rule('.todo-list li:focus .destroy, .todo-list li:hover .destroy') {
          display 'block'
        }
        
        rule('.todo-list li .destroy:focus, .todo-list li .destroy:hover') {
          color '#c18585'
        }
        
        rule('.todo-list li .destroy:after') {
          content '"×"'
          display 'block'
          height '100%'
          line_height '1.1'
        }
        
        media ('screen and (-webkit-min-device-pixel-ratio: 0)') {
          rule('.todo-list li .toggle, .toggle-all') {
            background 'none'
          }
          
          rule('.todo-list li .toggle') {
            height '40px'
          }
        }
              
      }
    }
  }
  
  def li_class_name(todo)
    classes = []
    classes << 'completed' if todo.completed?
    classes << 'editing' if todo.editing?
    classes.join(' ')
  end
end
