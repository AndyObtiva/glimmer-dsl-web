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

require 'glimmer/web/event_proxy'

module Glimmer
  module Web
    class ListenerProxy
      attr_reader :element, :event_attribute, :event_name, :dom_element, :selector, :listener, :js_listener, :original_event_listener

      def initialize(element:, event_attribute:, dom_element:, selector:, listener:)
        @element = element
        @event_attribute = event_attribute
        @event_name = event_attribute.sub(/^on/, '')
        @dom_element = dom_element
        @selector = selector
        @listener = listener
        @js_listener = lambda do |js_event|
          # TODO wrap event with a Ruby Event object before passing to listener
          event = EventProxy.new(js_event: js_event, listener: self)
          result = listener.call(event)
          result = true if result.nil?
          result
        end
        @original_event_listener = original_event_listener
      end
      
      def register
        @dom_element.on(@event_name, &@js_listener)
      end
      alias observe register
      alias reregister register
      
      def unregister
        # TODO contribute fix to opal to allow passing observer with & to off with selector not specified as nil
        @dom_element.off(@event_name, @js_listener)
        @element.listeners_for(@event_attribute).delete(self)
      end
      alias unobserve unregister
      alias deregister unregister
    end
  end
end
