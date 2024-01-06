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
    # Observe Model attribute @number_holder.number for changes and update View
    # Observer is automatically cleaned up if remove method is called on rendered HelloObserver
    # or its top-level element
    observe(@number_holder, :number) do
      number_string = @number_holder.number.to_s
      @number_input.value = number_string unless @number_input.value == number_string
      @range_input.value = number_string unless @range_input.value == number_string
    end
    # Bidirectional Data-Binding does the same thing automatically
    # Just disable the observe block above as well as the oninput listeners below
    # and enable the `value <=> [@number_holder, :number]` lines to try the data-binding version
    # Learn more about Bidirectional and Unidirectional Data-Binding in hello_data_binding.rb
  end
  
  markup {
    div {
      div {
        @number_input = input(type: 'number', value: @number_holder.number, min: 0, max: 100) {
          # oninput listener updates Model attribute @number_holder.number
          oninput do
            @number_holder.number = @number_input.value.to_i
          end
          
          # Bidirectional Data-Binding simplifies the implementation significantly
          # by enabling the following line and disabling oninput listeners as well
          # as the after_body observe block observer
          # Learn more about Bidirectional and Unidirectional Data-Binding in hello_data_binding.rb
#           value <=> [@number_holder, :number]
        }
      }
      div {
        @range_input = input(type: 'range', value: @number_holder.number, min: 0, max: 100) {
          # oninput listener updates Model attribute @number_holder.number
          oninput do
            @number_holder.number = @range_input.value.to_i
          end
          
          # Bidirectional Data-Binding simplifies the implementation significantly
          # by enabling the following line and disabling oninput listeners as well
          # as the after_body observe block observer
          # Learn more about Bidirectional and Unidirectional Data-Binding in hello_data_binding.rb
#           value <=> [@number_holder, :number]
        }
      }
    }
  }
end

Document.ready? do
  HelloObserver.render
end
