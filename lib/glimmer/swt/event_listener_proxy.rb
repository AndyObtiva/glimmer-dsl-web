module Glimmer
  module SWT
    class EventListenerProxy
      attr_reader :element_proxy, :event, :dom_element, :selector, :listener, :original_event_listener

      def initialize(element_proxy:, event:, dom_element:, selector:, listener:)
        @element_proxy = element_proxy
        @event = event
        @dom_element = dom_element
        @selector = selector
        @listener = listener
        @original_event_listener = original_event_listener
      end
      
      def register
        @dom_element.on(@event, @delegate)
      end
      alias observe register
      alias reregister register
      
      def unregister
        @dom_element.off(@event, @delegate)
      end
      alias unobserve unregister
      alias deregister unregister
    end
  end
end
