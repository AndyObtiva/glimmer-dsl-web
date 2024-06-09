Todo = Struct.new(:task, :completed, keyword_init: true) do
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
  
  FILTERS = ['all', 'active', 'completed']
  
  def active
    !completed
  end
  alias active? active
  alias completed? completed
end
