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

# TODO implement set_menu or self.menu=

require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    # Proxy for org.eclipse.swt.widgets.MenuItem
    #
    # Follows the Proxy Design Pattern since it's a proxy for an HTML based menu
    # Follows the Adapter Design Pattern since it's adapting a Glimmer DSL for SWT widget
    class MenuItemProxy < WidgetProxy
      STYLE = <<~CSS
        .menu-item.disabled {
          background-color: lightgrey;
          color: grey;
        }
        .menu-item.disabled .menu, .menu-item.disabled .menu * {
          display: none;
          opacity: 0;
        }
      CSS
      
      attr_accessor :accelerator # TODO consider doing something with it
    
      def initialize(parent, args, block)
        args.push(:push) if args.empty?
        super(parent, args, block)
        # TODO do not add the following event till post_add_content to avoid adding if already one on_widget_selected event existed
        on_widget_selected {
          # No Op, just trigger selection
        }
      end
      
      def post_initialize_child(child)
        @children << child
      end
      
      def cascade?
        args.include?(:cascade)
      end
      
      def push?
        args.include?(:push)
      end
      
      def radio?
        args.include?(:radio)
      end
      
      def check?
        args.include?(:check)
      end
      
      def separator?
        args.include?(:separator)
      end
      
      def text
        @text
      end
      
      def text=(value)
        @text = value
        dom_element.find('.menu-item-text').html(@text)
        @text
      end
      
      def selection
        @selection
      end
      
      def selection=(value)
        @selection = value
        icon_suffix = check? ? 'check' : 'bullet'
        dom_element.find('.menu-item-selection').toggle_class("ui-icon ui-icon-#{icon_suffix}", @selection)
        @selection
      end
      
      def toggle_selection!
        self.selection = !selection
      end
      
      def enabled=(value)
        @enabled = value
        dom_element.toggle_class('disabled', !@enabled)
        @enabled
      end
      
      def div_content
        div_attributes = {}
        icon_suffix = check? ? 'check' : 'bullet'
        div(div_attributes) {
          unless separator? # empty content automatically gets a separator style in jQuery-UI
            span(class: "menu-item-selection #{"ui-icon ui-icon-#{icon_suffix}" if selection}") {}
            span(class: 'ui-menu-icon ui-icon ui-icon-caret-1-e') {} if cascade? && !parent.bar?
            span(class: 'menu-item-text') {
              @text
            }
            ''
          end
        }
      end
      
      def root_menu
        the_menu = parent
        the_menu = the_menu.parent_menu until the_menu.root_menu?
        the_menu
      end
      
      def skip_content_on_render_blocks?
        true
      end
      
      def observation_request_to_event_mapping
        {
          'on_widget_selected' => {
            event: 'mouseup',
            event_handler: -> (event_listener) {
              -> (event) {
                if enabled && (push? || radio? || check?)
                  if check?
                    self.toggle_selection!
                  elsif radio? && !selection
                    parent.children.detect(&:selection)&.selection = false
                    self.selection = true
                  end
                  if !root_menu.bar?
                    remove_event_listener_proxies
                    root_menu.close
                  end
                  event_listener.call(event)
                end
              }
            },
          },
        }
      end
      
      def element
        'li'
      end
      
      def dom
        # TODO support rendering image
        @dom ||= html {
          li(id: id, class: "#{name} #{'disabled' unless enabled}") {
            div_content
          }
        }.to_s
      end
    end
  end
end
