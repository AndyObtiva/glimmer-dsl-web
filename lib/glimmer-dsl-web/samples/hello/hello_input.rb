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

class TimePresenter
  attr_accessor :date_time
  
  def initialize
    @date_time = Time.now
  end
end

@time_presenter = TimePresenter.new

include Glimmer

Document.ready? do
  div {
    form(style: 'display: grid; grid-auto-columns: 80px 260px;') { |address_form|
      label('Date Time: ', for: 'date-time-field')
      input(id: 'date-time-field', type: 'datetime-local') {
        # Bidirectional Data-Binding with <=> ensures input.value and @address.street
        # automatically stay in sync when either side changes
        value <=> [@time_presenter, :date_time]
      }
      
      label('Date: ', for: 'date-field')
      input(id: 'date-field', type: 'date') {
        # Bidirectional Data-Binding with <=> ensures input.value and @address.street
        # automatically stay in sync when either side changes
        value <=> [@time_presenter, :date_time]
      }
      
      label('Time: ', for: 'time-field')
      input(id: 'time-field', type: 'time') {
        # Bidirectional Data-Binding with <=> ensures input.value and @address.street
        # automatically stay in sync when either side changes
        value <=> [@time_presenter, :date_time]
      }
      
      style {
        <<~CSS
          #{address_form.selector} * {
            margin: 5px;
          }
          #{address_form.selector} input {
            grid-column: 2;
          }
        CSS
      }
    }
  }.render
end
