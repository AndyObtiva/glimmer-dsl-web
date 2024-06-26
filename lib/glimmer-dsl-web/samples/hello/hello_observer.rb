# Copyright (c) 2023-2024 Andy Maleh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'glimmer-dsl-web'

class NumberHolder
  attr_accessor :number
  
  def initialize
    self.number = 50
  end
end

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

Document.ready? do
  HelloObserver.render
end
