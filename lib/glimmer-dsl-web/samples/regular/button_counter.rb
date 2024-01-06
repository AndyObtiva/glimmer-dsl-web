require 'glimmer-dsl-web'

class Counter
  attr_accessor :count

  def initialize
    self.count = 0
  end
end

class ButtonCounter
  include Glimmer::Web::Component
  
  before_render do
    @counter = Counter.new
  end
  
  markup {
    div {
      button {
        # Unidirectional Data-Binding indicating that on every change to @counter.count, the value
        # is read and converted to "Click To Increment: #{value}  ", and then automatically
        # copied to button innerText (content) to display to the user
        inner_text <= [@counter, :count,
                        on_read: ->(value) { "Click To Increment: #{value}  " }
                      ]
        
        onclick {
          @counter.count += 1
        }
      }
    }
  }
end

ButtonCounter.render
