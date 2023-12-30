# Copyright (c) 2023 Andy Maleh
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

module Glimmer
  module Web
    class EventProxy
      attr_reader :js_event, :listener

      def initialize(js_event:, listener:)
        @js_event = js_event
        @listener = listener
      end
      
      def element = listener.element
      def event_name = listener.event_name
      def event_attribute = listener.event_attribute
      
      def original_event
        Native(`#{js_event.to_n}.originalEvent`)
      end
      
      def respond_to_missing?(method_name, include_private = false)
        property_name = method_name.to_s.camelcase
        super(method_name, include_private) ||
          js_event.respond_to?(method_name, include_private) ||
          `#{property_name} in #{original_event.to_n}`
      end
      
      def method_missing(method_name, *args, &block)
        property_name = method_name.to_s.camelcase
        if js_event.respond_to?(method_name, true)
          js_event.send(method_name, *args, &block)
        elsif `#{property_name} in #{original_event.to_n}`
          original_event[property_name]
        else
          super(method_name, *args, &block)
        end
      end
    end
  end
end
