require 'glimmer-dsl-web'

unless Object.const_defined?(:NumberHolder) # this is only needed in the sample app, not in real apps
  class NumberHolder
    attr_accessor :number
    
    def initialize
      self.number = 50
    end
  end
end

unless Object.const_defined?(:HelloObserver) # this is only needed in the sample app, not in real apps
  class HelloObserver
    include Glimmer::Web::Component
    
    before_render do
      @number_holder = NumberHolder.new
    end
    
    after_render do
      @number_input.value = @number_holder.number
      @range_input.value = @number_holder.number
      
      # Observe Model attribute @number_holder.number for changes and update View elements.
      # Observer is automatically cleaned up when `remove` method is called on rendered
      # HelloObserver web component or its top-level markup element (div)
      observe(@number_holder, :number) do
        number_string = @number_holder.number.to_s
        @number_input.value = number_string unless @number_input.value == number_string
        @range_input.value = number_string unless @range_input.value == number_string
      end
      # Bidirectional Data-Binding does the same thing automatically as per alternative sample: Hello, Observer (Data-Binding)!
    end
    
    markup {
      div {
        div {
          @number_input = input(type: 'number', min: 0, max: 100) {
            # oninput listener (observer) updates Model attribute @number_holder.number
            oninput do
              @number_holder.number = @number_input.value.to_i
            end
          }
        }
        div {
          @range_input = input(type: 'range', min: 0, max: 100) {
            # oninput listener (observer) updates Model attribute @number_holder.number
            oninput do
              @number_holder.number = @range_input.value.to_i
            end
          }
        }
      }
    }
  end
end

Document.ready? do
  HelloObserver.render
end
