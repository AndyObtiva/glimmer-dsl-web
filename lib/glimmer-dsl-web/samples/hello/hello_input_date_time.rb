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
  attr_accessor :date_time, :month_string, :week_string
  
  def initialize
    @date_time = Time.now
  end
  
  def month_string
    @date_time&.strftime('%Y-%m')
  end
  
  def month_string=(value)
    if value.match(/^\d{4}-\d{2}$/)
      year, month = value.split('-')
      self.date_time = Time.new(year, month, date_time.day, date_time.hour, date_time.min)
    end
  end
  
  def week_string
    return nil if @date_time.nil?
    year = @date_time.year
    week = ((@date_time.yday / 7).to_i + 1).to_s.rjust(2, '0')
    "#{year}-W#{week}"
  end
  
  def date_time_string
    @date_time&.strftime('%Y-%m-%dT%H:%M')
  end
  
  def date_time_string=(value)
    if value.match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/)
      date_time_parts = value.split('T')
      date_parts = date_time_parts.first.split('-')
      time_parts = date_time_parts.last.split(':')
      self.date_time = Time.new(*date_parts, *time_parts)
    end
  end
end

@time_presenter = TimePresenter.new

include Glimmer

Document.ready? do
  div {
    div(style: 'display: grid; grid-auto-columns: 130px 260px;') { |container_div|
      label('Date Time: ', for: 'date-time-field')
      input(id: 'date-time-field', type: 'datetime-local') {
        # Bidirectional Data-Binding with <=> ensures input.value and @time_presenter.date_time
        # automatically stay in sync when either side changes
        value <=> [@time_presenter, :date_time]
      }
      
      label('Date: ', for: 'date-field')
      input(id: 'date-field', type: 'date') {
        value <=> [@time_presenter, :date_time]
      }
      
      label('Time: ', for: 'time-field')
      input(id: 'time-field', type: 'time') {
        value <=> [@time_presenter, :date_time]
      }
      
      label('Month: ', for: 'month-field')
      input(id: 'month-field', type: 'month') {
        value <=> [@time_presenter, :month_string, computed_by: :date_time]
      }
      
      label('Week: ', for: 'week-field')
      input(id: 'week-field', type: 'week', disabled: true) {
        value <=> [@time_presenter, :week_string, computed_by: :date_time]
      }
      
      label('Time String: ', for: 'time-string-field')
      input(id: 'time-string-field', type: 'text') {
        value <=> [@time_presenter, :date_time_string, computed_by: :date_time]
      }
      
      style {
        <<~CSS
          #{container_div.selector} * {
            margin: 5px;
          }
          #{container_div.selector} label {
            grid-column: 1;
          }
          #{container_div.selector} input {
            grid-column: 2;
          }
        CSS
      }
    }
  }
end
