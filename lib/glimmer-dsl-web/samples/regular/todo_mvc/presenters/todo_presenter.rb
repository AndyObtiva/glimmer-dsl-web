require 'glimmer/data_binding/observer'

require_relative '../models/todo'

class TodoPresenter
  attr_accessor :todos, :can_clear_completed, :active_todo_count
  attr_reader :new_todo, :filter
  
  def initialize
    @todos = Todo.all.clone
    @new_todo = Todo.new(task: '')
    @filter = 'all'
    # TODO remove todo tasks when done development
    [
      Todo.new(task: 'Go Shopping', completed: false),
      Todo.new(task: 'Exercise', completed: true),
      Todo.new(task: 'Clean', completed: false)
    ].each { |todo| create_todo(todo) }
    refresh_todo_stats
  end
  
  def create_todo(todo = nil)
    todo ||= new_todo.clone
    Todo.all.prepend(todo)
    observers_for_todo_stats[todo.object_id] = todo_stat_observer.observe(todo, :completed) unless observers_for_todo_stats.has_key?(todo.object_id)
    refresh_todos_with_filter
    refresh_todo_stats
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
    delete(todo)
    refresh_todos_with_filter
  end
  
  def clear_completed
    Todo.completed.each { |todo| delete(todo) }
    refresh_todos_with_filter
    refresh_todo_stats
  end
  
  def toggle_all_completed
    target_completed_value = Todo.active.any?
    todos_to_update = target_completed_value ? Todo.active : Todo.completed
    todos_to_update.each { |todo| todo.completed = target_completed_value }
  end
  
  private
  
  def delete(todo)
    Todo.all.delete(todo)
    observer_registration = observers_for_todo_stats.delete(todo.object_id)
    observer_registration&.deregister
  end
  
  def observers_for_todo_stats
    @observers_for_todo_stats = {}
  end
  
  def todo_stat_observer
    @todo_stat_observer ||= Glimmer::DataBinding::Observer.proc { refresh_todo_stats }
  end
  
  def refresh_todo_stats
    refresh_can_clear_completed
    refresh_active_todo_count
  end
  
  def refresh_can_clear_completed
    self.can_clear_completed = Todo.completed.any?
  end
  
  def refresh_active_todo_count
    self.active_todo_count = Todo.active.count
  end
end
