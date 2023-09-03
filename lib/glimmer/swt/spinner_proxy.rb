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

module Glimmer
  module SWT
    class SpinnerProxy < WidgetProxy
      attr_reader :minimum, :maximum, :increment, :page_increment, :digits
    
      def initialize(parent, args, block)
        super(parent, args, block)
        @increment = 1
        @digits = 0
        dom_element.spinner
      end

      def selection=(value, format_digits: true)
        old_value = @selection.to_f
        if @selection.nil?
          @selection = value.to_f / divider
        else
          @selection = value.to_f
        end
        if value.to_i != old_value.to_i
          if format_digits && @digits.to_i > 0
            new_value = "%0.#{@digits.to_i}f" % @selection
            dom_element.value = new_value
          else
            dom_element.value = @selection if @selection != 0
          end
        end
      end
      alias set_selection selection=
      
      def selection
        @selection && @selection * divider
      end
      
      def text=(value)
        self.selection = value.to_f
      end
      
      def text
        self.selection.to_s
      end
      
      def minimum=(value)
        @minimum = value.to_f / divider
        dom_element.spinner('option', 'min', @minimum)
      end
      
      def maximum=(value)
        @maximum = value.to_f / divider
        dom_element.spinner('option', 'max', @maximum)
      end
      
      def increment=(value)
        @increment = value.to_f / divider
        dom_element.spinner('option', 'step', @increment)
      end
      
      def page_increment=(value)
        @page_increment = value.to_f / (@increment * divider)
        dom_element.spinner('option', 'page', @page_increment)
      end
      
      def divider
        ('1' + '0'*@digits.to_i).to_f
      end
      
      def digits=(value)
        @digits = value
        dom_element.spinner('option', 'numberFormat', "n") if @digits.to_i > 0
      end
      
      def element
        'input'
      end
      
      def observation_request_to_event_mapping
        {
          'on_widget_selected' => [
            {
              event: 'change',
              event_handler: -> (event_listener) {
                -> (event) {
                  self.selection = event.target.value
                  event_listener.call(event)
                }
              }
            },
            {
              event: 'keyup',
              event_handler: -> (event_listener) {
                -> (event) {
                  @keyup = true # ensures spinstop event does not set selection if caused by key up entry
                }
              }
            },
            {
              event: 'spin',
              event_handler: -> (event_listener) {
                -> (event) {
                  @keyup = false
                }
              }
            },
            {
              event: 'spinstop',
              event_handler: -> (event_listener) {
                -> (event) {
                  self.set_selection(event.target.value, format_digits: !@keyup)
                  @keyup = false
                  event_listener.call(event)
                }
              }
            },
          ],
          'on_modify_text' => {
            event: 'keyup',
            event_handler: -> (event_listener) {
              -> (event) {
                # TODO consider unifying this event handler with on_key_pressed by relying on its result instead of hooking another keyup event
                if @last_key_pressed_event.nil? || @last_key_pressed_event.doit
                  self.text = event.target.value
                  event_listener.call(event)
                else
                  # TODO Fix doit false, it's not stopping input
                  event.prevent
                  event.prevent_default
                  event.stop_propagation
                  event.stop_immediate_propagation
                end
              }
            }
          },
        }
      end
      
      def dom
        text_text = @text
        text_id = id
        text_style = "min-width: 27px; #{css}"
        text_class = name
        # TODO `:style` key is duplicated twice
        options = {type: 'text', id: text_id, style: text_style, class: text_class, value: text_text}
        options = options.merge('disabled': 'disabled') unless @enabled
        @dom ||= html {
          input(options)
        }.to_s
      end
    end
  end
end
