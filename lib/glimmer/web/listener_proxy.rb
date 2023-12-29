module Glimmer
  module Web
    class ListenerProxy
      attr_reader :element_proxy, :event, :dom_element, :selector, :listener, :original_event_listener

      def initialize(element_proxy:, event:, dom_element:, selector:, listener:)
        @element_proxy = element_proxy
        @event = event
        @dom_element = dom_element
        @selector = selector
        @listener = listener
        @js_listener = lambda do |event|
          event.prevent
          event.prevent_default
          event.stop_propagation
          event.stop_immediate_propagation
          # TODO wrap event with a Ruby Event object before passing to listener
          listener.call(event)
          false
        end
        @original_event_listener = original_event_listener
      end
      
      def register
        @dom_element.on(@event, &@js_listener)
      end
      alias observe register
      alias reregister register
      
      def unregister
        # TODO contribute fix to opal to allow passing observer with & to off with selector not specified as nil
        @dom_element.off(@event, @js_listener)
      end
      alias unobserve unregister
      alias deregister unregister
    end
  end
end
