require 'glimmer-dsl-web'

unless Object.const_defined?(:TimePresenter) # this is only needed in sample selector app due to file reloading, but not in real apps.
  class TimePresenter
    attr_accessor :date_time, :week_string
    
    def initialize
      @date_time = Time.now
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
      elsif value.strip.empty?
        self.date_time = nil
      end
    end
  end
end

unless Object.const_defined?(:HelloInputDateTime) # this is only needed in sample selector app due to file reloading, but not in real apps.
  class HelloInputDateTime
    include Glimmer::Web::Component
    
    before_render do
      @time_presenter = TimePresenter.new
    end
    
    after_render do
      observe(@time_presenter, :date_time) do |new_date_time|
        @date_time_field.value = new_date_time
        @date_field.value = new_date_time
        @time_field.value = new_date_time
        @month_field.value = new_date_time
        @week_field.value = @time_presenter.week_string
        @time_string_field.value = @time_presenter.date_time_string
      end
    end
    
    markup {
      div {
        div(style: 'display: grid; grid-auto-columns: 130px 260px;') { |container_div|
          label('Date Time: ', for: 'date-time-field')
          @date_time_field = input(id: 'date-time-field', type: 'datetime-local', value: @time_presenter.date_time) {
            oninput do |event|
              @time_presenter.date_time = @date_time_field.value
            end
          }
          
          label('Date: ', for: 'date-field')
          @date_field = input(id: 'date-field', type: 'date', value: @time_presenter.date_time) {
            oninput do |event|
              @time_presenter.date_time = @date_field.value
            end
          }
    
          label('Time: ', for: 'time-field')
          @time_field = input(id: 'time-field', type: 'time', value: @time_presenter.date_time) {
            oninput do |event|
              @time_presenter.date_time = @time_field.value
            end
          }
  
          label('Month: ', for: 'month-field')
          @month_field = input(id: 'month-field', type: 'month', value: @time_presenter.date_time) {
            oninput do |event|
              @time_presenter.date_time = @month_field.value
            end
          }
  
          label('Week: ', for: 'week-field')
          @week_field = input(id: 'week-field', type: 'week', disabled: true, value: @time_presenter.week_string)
  
          label('Time String: ', for: 'time-string-field')
          @time_string_field = input(id: 'time-string-field', type: 'text', value: @time_presenter.date_time_string) {
            oninput do |event|
              @time_presenter.date_time_string = @time_string_field.value
            end
          }
          
          style {
            r("#{container_div.selector} *") {
              margin '5px'
            }
            r("#{container_div.selector} label") {
              grid_column '1'
            }
            r("#{container_div.selector} input") {
              grid_column '2'
            }
          }
        }
      }
    }
  end
end

Document.ready? do
  HelloInputDateTime.render
end
