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
    class ScaleProxy < WidgetProxy
      STYLE = <<~CSS
        .scale {
          width: 100%;
        }
      CSS
          
      attr_reader :selection, :minimum, :maximum, :increment
    
      def initialize(parent, args, block)
        super(parent, args, block)
        dom_element.slider
      end

      def selection=(value)
        old_value = @selection.to_f
        @selection = value.to_f
        dom_element.slider('option', 'value', @selection)
      end
      alias set_selection selection=
      
      def minimum=(value)
        @minimum = value.to_f
        dom_element.slider('option', 'min', @minimum)
      end
      
      def maximum=(value)
        @maximum = value.to_f
        dom_element.slider('option', 'max', @maximum)
      end
      
      def increment=(value)
        @increment = value.to_f
        dom_element.slider('option', 'step', @increment)
      end
      
      def element
        'div'
      end
      
      def observation_request_to_event_mapping
        {
          'on_widget_selected' => [
            {
              event: 'change',
              event_handler: -> (event_listener) {
                -> (event) {
                  self.selection = dom_element.slider('option', 'value')
                  event_listener.call(event)
                }
              }
            },
            {
              event: 'slidestop',
              event_handler: -> (event_listener) {
                -> (event) {
                  self.selection = dom_element.slider('option', 'value')
                  event_listener.call(event)
                }
              }
            },
          ],
        }
      end
      
      def dom
        scale_selection = @selection
        scale_id = id
        scale_style = css
        scale_class = name
        options = {type: 'text', id: scale_id, style: scale_style, class: scale_class, value: scale_selection}
        options = options.merge('disabled': 'disabled') unless @enabled
        @dom ||= html {
          div(options)
        }.to_s
      end
    end
  end
end
