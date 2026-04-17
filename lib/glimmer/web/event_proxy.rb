# backtick_javascript: true

module Glimmer
  module Web
    class EventProxy
      attr_reader :js_event, :listener

      # Instantiates EventProxy
      # When js_event is nil, it is a custom event
      def initialize(listener:, js_event: nil)
        @listener = listener
        @js_event = js_event
      end
      
      def element = listener.element
      def event_name = listener.event_name
      def event_attribute = listener.event_attribute
      
      def original_event
        return if js_event.nil?
        Native(`#{js_event.to_n}.originalEvent`)
      end
      
      def respond_to_missing?(method_name, include_private = false)
        property_name = method_name.to_s.camelcase
        super(method_name, include_private) ||
          js_event.respond_to?(method_name, include_private) ||
          (original_event && `#{property_name} in #{original_event.to_n}`)
      end
      
      def method_missing(method_name, *args, &block)
        property_name = method_name.to_s.camelcase
        if js_event.respond_to?(method_name, true)
          js_event.send(method_name, *args, &block)
        elsif (original_event && `#{property_name} in #{original_event.to_n}`)
          original_event[property_name]
        else
          super(method_name, *args, &block)
        end
      end
    end
  end
end
