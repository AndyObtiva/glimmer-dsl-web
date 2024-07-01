Todo = Struct.new(:task, :completed, :editing, :deleted, keyword_init: true) do
  alias completed? completed
  alias editing? editing
  alias deleted? deleted
  
  def active = !completed
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
