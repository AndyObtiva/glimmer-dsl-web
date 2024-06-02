Todo = Struct.new(:task, :completed, keyword_init: true) do
  class << self
    attr_accessor :all
  
    def all
      @all ||= [
        Todo.new(task: 'Go Shopping', completed: false),
        Todo.new(task: 'Exercise', completed: true),
        Todo.new(task: 'Clean', completed: false)
      ]
    end
    
    def active
      all.select(&:active?)
    end
    
    def completed
      all.select(&:completed?)
    end
  end
  
  FILTERS = ['all', 'active', 'completed']
  
  def active
    !completed
  end
  alias active? active
  alias completed? completed
end
