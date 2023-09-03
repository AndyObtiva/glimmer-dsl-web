class Class
  def inherited(klass)
    @descendants ||= []
    @descendants << klass
  end
  
  def descendants
    @descendants.to_collection.map { |klass| [klass] + (klass.descendants if klass.respond_to?(:descendants)).to_a }.flatten.compact
  end
end
