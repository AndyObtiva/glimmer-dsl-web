require_relative 'todo_list_item'

class TodoList
  include Glimmer::Web::Component
  
  option :presenter
  
  after_render do
    observe(presenter, :created_todo) do |todo|
      @todo_ul.content { # re-open todo ul content to add created todo
        todo_list_item(presenter:, todo:)
      }
    end
  end
  
  markup {
    main(class: 'main') {
      style <= [ presenter, :todos,
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
      
      @todo_ul = ul {
        class_name <= [presenter, :filter,
                        on_read: ->(filter) { "todo-list #{filter}" }
                      ]
      
        presenter.todos.each do |todo|
          todo_list_item(presenter:, todo:)
        end
      }
      
      style {
        todo_list_styles
      }
    }
  }
  
  def todo_list_styles
    TodoListItem.todo_list_item_styles
    
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
    
    rule('.toggle-all:focus+label, .toggle:focus+label, :focus') {
      box_shadow '0 0 2px 2px #cf7d7d'
      outline '0'
    }
    
    rule('.todo-list') {
      list_style 'none'
      margin '0'
      padding '0'
    }
    
    rule('.todo-list.active li.completed') {
      display 'none'
    }
    
    rule('.todo-list.completed li.active') {
      display 'none'
    }
  end
end
