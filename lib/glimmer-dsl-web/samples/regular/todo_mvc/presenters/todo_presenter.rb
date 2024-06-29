require 'glimmer/data_binding/observer'

require_relative '../models/todo'

class TodoPresenter
  FILTER_ROUTE_REGEXP = /\#\/([^\/]*)$/
  
  attr_accessor :todos, :can_clear_completed, :active_todo_count
  attr_reader :new_todo, :filter
  
  def initialize
    @todos = Todo.all.clone
    @new_todo = Todo.new(task: '')
    @filter = :all
    refresh_todo_stats
  end
  
  def create_todo(todo = nil)
    todo ||= new_todo.clone
    Todo.all.prepend(todo)
    observe_todo_completion_to_update_todo_stats(todo)
    refresh_todos_with_filter
    refresh_todo_stats
    new_todo.task = ''
  end
  
  def observe_todo_completion_to_update_todo_stats(todo)
    if !observers_for_todo_stats.has_key?(todo.object_id)
      observers_for_todo_stats[todo.object_id] = todo_stat_observer.observe(todo, :completed)
    end
  end
  
  def refresh_todos_with_filter
    self.todos = Todo.send(filter).clone
  end
  
  def filter=(filter)
    return if filter == @filter
    @filter = filter
    refresh_todos_with_filter
  end
  
  def destroy(todo)
    delete(todo)
    refresh_todos_with_filter
    refresh_todo_stats
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
  
  def setup_filter_routes
    @filter_router_function = -> (event) { apply_route_filter }
    $$.addEventListener('popstate', &@filter_router_function)
    apply_route_filter
  end
  
  def apply_route_filter
    route_filter_match = $$.document.location.href.to_s.match(FILTER_ROUTE_REGEXP)
    return if route_filter_match.nil?
    route_filter = route_filter_match[1]
    route_filter = 'all' if route_filter == ''
    self.filter = route_filter
  end
  
  def unsetup_filter_routes
    $$.removeEventListener('popstate', &@filter_router_function)
    @filter_router_function = nil
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
