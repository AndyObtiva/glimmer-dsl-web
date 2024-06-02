require_relative '../models/todo'

class TodoPresenter
  attr_accessor :todos
  attr_reader :new_todo, :filter
  
  def initialize
    @todos = Todo.all.clone
    @new_todo = Todo.new(task: '')
    @filter = 'all'
  end
  
  def create_todo
    todo = new_todo.clone
    Todo.all << todo
    refresh_todos_with_filter
    new_todo.task = ''
  end
  
  def refresh_todos_with_filter
    self.todos = Todo.send(filter).clone
  end
  
  def filter=(filter)
    @filter = filter
    refresh_todos_with_filter
  end
  
  def destroy(todo)
    Todo.all.delete(todo)
    refresh_todos_with_filter
  end
end
