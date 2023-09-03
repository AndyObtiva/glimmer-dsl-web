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

require 'glimmer/swt/composite_proxy'

module Glimmer
  module SWT
    class TabItemProxy < CompositeProxy
      include Glimmer
      attr_reader :text, :content_visible, :tool_tip_text, :image
      
      def initialize(parent, args, block)
        super(parent, args, block)
        content {
          on_widget_selected {
            @parent.hide_all_tab_content
            show
          }
        }
      end
      
      def show
        @content_visible = true
        dom_element.remove_class('hide')
        tab_dom_element.add_class('selected')
      end
      
      def hide
        @content_visible = false
        dom_element.add_class('hide')
        tab_dom_element.remove_class('selected')
      end
    
      def text=(value)
        @text = value
        tab_dom_element.find('span').html(@text)
      end
      
      def image=(value)
        @image = value
        if @image.is_a?(String)
          tab_dom_element.find('img').attr('src', @image)
          tab_dom_element.find('img').css('padding-right', '5px')
        end
      end
      
      def tool_tip_text=(value)
        @tool_tip_text = value
        tab_dom_element.attr('title', @tool_tip_text) if !@tool_tip_text.to_s.empty?
      end
      
      def dispose
        tab_index = parent.children.to_a.index(self)
        tab_dom_element.remove
        super
        if @content_visible
          @content_visible = false
          parent.hide_all_tab_content
          tab_to_show = parent.children.to_a[tab_index]
          tab_to_show ||= parent.children.to_a[tab_index - 1]
          tab_to_show&.show
        end
      end
    
      def selector
        super + '-tab'
      end
      
      def observation_request_to_event_mapping
        {
          'on_widget_selected' => {
            event: 'click'
          },
        }
      end
      
      def listener_path
        tab_path
      end
      
      def tab_path
        "#{parent.tabs_path} > ##{tab_id}"
      end
      
      def tab_dom_element
        Document.find(tab_path)
      end
      
      def tab_id
        id + '-tab'
      end
        
      # This contains the clickable tab area with tab names
      def tab_dom
        @tab_dom ||= html {
          a(href: '#', id: tab_id, class: "tab") {
            img {}
            span { @text }
          }
        }.to_s
      end
      
      # This contains the tab content
      def dom
        tab_item_id = id
        tab_item_class_string = [name, 'hide'].join(' ')
        @dom ||= html {
          div(id: tab_item_id, class: tab_item_class_string) {
          }
        }.to_s
      end
    end
  end
end
