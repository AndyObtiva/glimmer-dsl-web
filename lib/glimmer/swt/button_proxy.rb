# Copyright (c) 2020-2022 Andy Maleh
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

require 'glimmer/swt/widget_proxy'
require 'glimmer/swt/radio_proxy'
require 'glimmer/swt/checkbox_proxy'

module Glimmer
  module SWT
    class ButtonProxy < WidgetProxy
      class << self
        def create(keyword, parent, args, block)
          if args.to_a.include?(:radio)
            RadioProxy.new(parent, args, block)
          elsif args.to_a.include?(:check)
            CheckboxProxy.new(parent, args, block)
          elsif args.to_a.include?(:arrow)
            ArrowProxy.new(parent, args, block)
          else
            new(parent, args, block)
          end
        end
      end
    
      attr_reader :text
      
      def text=(value)
        @text = value
        dom_element.html(@text)
      end
      
      def font=(value)
        super(value)
        dom_element.css('height', @font.height + 10) if @font&.height
      end
      
      def element
        'button'
      end

      def observation_request_to_event_mapping
        myself = self
        {
          'on_widget_selected' => {
            event: 'click',
            event_handler: -> (event_listener) {
              -> (event) {
                event.define_singleton_method(:widget) {myself}
                doit = true
                event.define_singleton_method(:doit=) do |value|
                  doit = value
                end
                event.define_singleton_method(:doit) { doit }
                event_listener.call(event)
              }
            }
          },
        }
      end
      
      def dom
        input_text = @text
        input_id = id
        input_style = "min-width: 32px; min-height: 32px; #{css}"
        input_args = {}
        input_disabled = @enabled ? {} : {'disabled': 'disabled'}
        input_args = input_args.merge(type: 'password') if has_style?(:password)
        @dom ||= html {
          # TODO `:style` key is duplicated twice
          button(input_args.merge(id: input_id, class: name, style: input_style).merge(input_disabled)) {
            input_text.to_s == '' ? '&nbsp;' : input_text
          }
        }.to_s
      end
    end
  end
end
