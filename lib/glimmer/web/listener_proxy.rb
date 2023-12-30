module Glimmer
  module Web
    class ListenerProxy
      attr_reader :element_proxy, :event, :dom_element, :selector, :listener, :original_event_listener

      def initialize(element_proxy:, event:, dom_element:, selector:, listener:)
        @element_proxy = element_proxy
        @event = event
        @jquery_event = event.sub(/^on/, '')
        @dom_element = dom_element
        @selector = selector
        @listener = listener
        @js_listener = lambda do |event|
          # TODO wrap event with a Ruby Event object before passing to listener
          result = listener.call(event)
          result = true if result.nil?
          result
        end
        @original_event_listener = original_event_listener
      end
      
      def register
        @dom_element.on(@jquery_event, &@js_listener)
      end
      alias observe register
      alias reregister register
      
      def unregister
        # TODO contribute fix to opal to allow passing observer with & to off with selector not specified as nil
        @dom_element.off(@jquery_event, @js_listener)
        @element_proxy.listeners_for(@event).delete(self)
      end
      alias unobserve unregister
      alias deregister unregister
    end
  end
end
