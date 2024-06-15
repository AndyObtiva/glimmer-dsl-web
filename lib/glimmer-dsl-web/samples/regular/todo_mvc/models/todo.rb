Todo = Struct.new(:task, :completed, :editing, keyword_init: true) do
  class << self
    attr_writer :all
    
    def all
      @all ||= []
    end
    
    def active
      all.select(&:active?)
    end
    
    def completed
      all.select(&:completed?)
    end
  end
  
  FILTERS = [:all, :active, :completed]
  
  alias completed? completed
  alias editing? editing
  
  def active
    !completed
  end
  alias active? active
  
  def start_editing
    return if editing?
    @original_task = task
    self.editing = true
  end
  
  def cancel_editing
    return unless editing?
    self.task = @original_task
    self.editing = false
  end
  
  def save_editing
    return unless editing?
    self.editing = false
  end
end
