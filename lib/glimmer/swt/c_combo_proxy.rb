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
require 'glimmer/swt/combo_proxy'

module Glimmer
  module SWT
    class CComboProxy < ComboProxy
      def post_add_content
        dom_element.selectmenu
        c_combo_dom_element.css('width', 'initial')
      end
      
      def font=(value)
        @font = value.is_a?(FontProxy) ? value : FontProxy.new(self, value)
        c_combo_dom_element.css('font-family', @font.name) unless @font.nil?
        c_combo_dom_element.css('font-style', 'italic') if @font&.style == :italic
        c_combo_dom_element.css('font-weight', 'bold') if @font&.style == :bold
        c_combo_dom_element.css('font-size', "#{@font.height}px") unless @font.nil?
      end
      
      def text=(value)
        super(value)
        c_combo_text_element.text(value)
      end
      
      def c_combo_path
        "##{id}-button"
      end
      
      def c_combo_dom_element
        Document.find(c_combo_path)
      end
      
      def c_combo_text_path
        c_combo_path + ' .ui-selectmenu-text'
      end
      
      def c_combo_text_element
        Document.find(c_combo_text_path)
      end
      
      def observation_request_to_event_mapping
        super.merge(
          'on_widget_selected' => [
            {
              event: 'selectmenuchange',
              event_handler: -> (event_listener) {
                -> (event) {
                  self.text = event.target.value
                  event_listener.call(event)
                }
              }
            },
          ],
        )
      end
    end
  end
  
end
