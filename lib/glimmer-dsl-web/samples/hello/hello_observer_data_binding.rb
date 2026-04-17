require 'glimmer-dsl-web'

class NumberHolder
  attr_accessor :number
  
  def initialize
    self.number = 50
  end
end

class HelloObserverDataBinding
  include Glimmer::Web::Component
  
  before_render do
    @number_holder = NumberHolder.new
  end
  
  markup {
    div {
      div {
        input(type: 'number', min: 0, max: 100) {
          value <=> [@number_holder, :number]
        }
      }
      div {
        input(type: 'range', min: 0, max: 100) {
          value <=> [@number_holder, :number]
        }
      }
    }
  }
end

Document.ready? do
  HelloObserverDataBinding.render
end
