module Glimmer
  module Util
    class Debounce
      INTERVAL_CHECK_IN_MILLISECONDS = 50
    
      attr_reader :work
    
      def initialize(&work)
        @work = work
      end
    
      def call(delay: 300, debounce: true)
        if delay.nil? || delay == 0 || !debounce
          @call_in_progress = @call_request_time = nil
          work.call
          return
        end
        @call_request_time = Time.now
        return if @call_in_progress
    
        @call_in_progress  = true
        debouncer          = lambda do
          if (Time.now - @call_request_time) < (delay / 1000.0)
            Async::Timeout.new(INTERVAL_CHECK_IN_MILLISECONDS, &debouncer)
          else
            @call_in_progress = @call_request_time = nil
            work.call
          end
        end
        Async::Timeout.new(delay, &debouncer)
      end
    end
  end
end
