require 'glimmer/data_binding/observer'

require_relative '../models/todo'

class TodoPresenter
  FILTERS = [:all, :active, :completed]
  FILTER_ROUTE_REGEXP = /\#\/([^\/]*)$/
  
  attr_accessor :can_clear_completed, :active_todo_count, :created_todo
  attr_reader :todos, :new_todo, :filter
  
  def initialize
    @todos = []
    @new_todo = Todo.new(task: '')
    @filter = :all
    @can_clear_completed = false
    @active_todo_count = 0
    todo_stat_refresh_observer.observe(todos) # refresh stats if todos array adds/removes todo objects
  end
  
  def active_todos = todos.select(&:active?)
  
  def completed_todos = todos.select(&:completed?)
  
  def create_todo
    todo = new_todo.clone
    todos.append(todo)
    observe_todo_completion_to_update_todo_stats(todo)
    new_todo.task = ''
    self.created_todo = todo # notifies View observer indirectly to add created todo to todo list
  end
  
  def filter=(filter)
    return if filter == @filter
    @filter = filter
  end
  
  def destroy(todo)
    delete(todo)
  end
  
  def clear_completed
    refresh_todo_stats do
      completed_todos.each { |todo| delete(todo) }
    end
  end
  
  def toggle_all_completed
    target_completed_value = active_todos.any?
    todos_to_update = target_completed_value ? active_todos : completed_todos
    refresh_todo_stats do
      todos_to_update.each { |todo| todo.completed = target_completed_value }
    end
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
  
  def observe_todo_completion_to_update_todo_stats(todo)
    # saving observer registration object to deregister when deleting todo
    observers_for_todo_stats[todo.object_id] = todo_stat_refresh_observer.observe(todo, :completed)
  end
  
  def todo_stat_refresh_observer
    @todo_stat_refresh_observer ||= Glimmer::DataBinding::Observer.proc { refresh_todo_stats }
  end
  
  def delete(todo)
    todos.delete(todo)
    observer_registration = observers_for_todo_stats.delete(todo.object_id)
    observer_registration&.deregister
    todo.deleted = true # notifies View observer indirectly to delete todo
  end
  
  def observers_for_todo_stats
    @observers_for_todo_stats = {}
  end
  
  def refresh_todo_stats(&work_before_refresh)
    if work_before_refresh
      @do_not_refresh_todo_stats = true
      work_before_refresh.call
      @do_not_refresh_todo_stats = nil
    end
    return if @do_not_refresh_todo_stats
    refresh_can_clear_completed
    refresh_active_todo_count
  end
  
  def refresh_can_clear_completed
    self.can_clear_completed = todos.any?(&:completed?)
  end
  
  def refresh_active_todo_count
    self.active_todo_count = active_todos.count
  end
end
