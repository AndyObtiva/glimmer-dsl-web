require 'glimmer/web/event_proxy'

module Glimmer
  module Web
    class ListenerProxy
      attr_reader :element, :event_attribute, :event_name, :dom_element, :selector, :js_listener, :original_event_listener

      def initialize(element:, event_attribute:, dom_element:, selector:, original_event_listener:)
        @element = element
        @event_attribute = event_attribute
        @event_name = event_attribute.sub(/^on_/, '').sub(/^on/, '')
        @dom_element = dom_element
        @selector = selector
        if !event_attribute.start_with?('on_') # custom event
          @js_listener = lambda do |js_event|
            event = EventProxy.new(js_event: js_event, listener: self)
            result = original_event_listener.call(event)
            result = true if result.nil?
            result
          end
        end
        @original_event_listener = original_event_listener
      end
      
      def register
        @dom_element.on(@event_name, &@js_listener) unless @js_listener.nil?
      end
      alias observe register
      alias reregister register
      
      def unregister
        # TODO contribute fix to opal to allow passing observer with & to off with selector not specified as nil
        @dom_element.off(@event_name, @js_listener) unless @js_listener.nil?
        @element.listeners_for(@event_attribute).delete(self)
      end
      alias unobserve unregister
      alias deregister unregister
    end
  end
end
