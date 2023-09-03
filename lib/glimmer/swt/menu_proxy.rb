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
require 'glimmer/swt/menu_item_proxy'

module Glimmer
  module SWT
    # Proxy for org.eclipse.swt.widgets.Menu
    #
    # Functions differently from other widget proxies.
    #
    # Glimmer automatically detects if this is a drop down menu
    # or pop up menu from its parent if no SWT style is passed in.
    #
    # There are 3 possibilities:
    # - SWT :bar style is passed in: Menu Bar
    # - Parent is ShellProxy: Pop Up Menu (having style :pop_up)
    # - Parent is another Menu: Drop Down Menu (having style :drop_down)
    #
    # In order to get the SWT Menu object, one must call `#swt_widget`.
    #
    # In the case of a Drop Down menu, this automatically creates an
    # SWT MenuItem object with style :cascade
    #
    # In order to retrieve the menu item widget proxy, one must call `#menu_item_proxy`
    #
    # Follows the Proxy Design Pattern
    class MenuProxy < WidgetProxy
      STYLE = <<~CSS
        .menu.menu-bar {
          position: absolute;
          top: -30px;
          border-radius: 0;
          width: 100%;
        }
        .menu.menu-bar .menu {
          border-radius: 0;
        }
        .menu-bar .menu-item {
          width: 180px;
        }
        .menu-bar > .menu-item {
          display: inline-block;
          width: 150px;
        }
        li.menu-item {
          padding-left: initial;
          padding-right: initial;
        }
        .menu {
          /* TODO consider auto-sizing in the future */
          font-size: initial;
          border-radius: 5px;
        }
        .menu:not(.menu-bar) {
          width: 150px;
        }
        .menu-bar .ui-menu:not(.menu-bar) {
          width: 180px;
        }
        .ui-menu-item:first-child > .ui-menu-item-wrapper {
          border-top-left-radius: 5px;
          border-top-right-radius: 5px;
        }
        .ui-menu-item:last-child > .ui-menu-item-wrapper {
          border-bottom-left-radius: 5px;
          border-bottom-right-radius: 5px;
        }
        .menu-bar .ui-menu-item:first-child > .ui-menu-item-wrapper {
          border-top-left-radius: 0;
          border-top-right-radius: 0;
        }
        .menu-bar .ui-menu-item:last-child > .ui-menu-item-wrapper {
          border-bottom-left-radius: 0;
          border-bottom-right-radius: 0;
        }
        
      CSS
      
      attr_reader :menu_item_proxy, :menu_parent

      def initialize(parent, args, block = nil)
        # TODO refactor/simplify code below
        @children = []
        index = args.delete(args.last) if args.last.is_a?(Numeric)
        args = args.map {|arg| arg.is_a?(String) ? arg.to_sym : arg}
        if parent.is_a?(ShellProxy)
          args = args.unshift(:bar)
        elsif parent.is_a?(MenuProxy)
          args = args.unshift(:drop_down)
        else
          args = args.unshift(:pop_up)
        end
        if parent.is_a?(MenuProxy)
          @menu_item_proxy = SWT::WidgetProxy.for('menu_item', parent, [:cascade] + [index].compact, block)
          super(@menu_item_proxy, args, nil)
          @menu_item_proxy.menu = self
        elsif parent.is_a?(ShellProxy)
          super(parent, args, nil)
        else # widget pop up
          super(parent, args, nil)
        end
        
        if bar?
          # Assumes a parent shell
          parent.menu_bar = self
        elsif pop_up?
          parent.menu = self
        end
        
        # TODO IMPLEMENT PROPERLY
#         on_focus_lost {
#           dispose
#         }
      end
      
      def bar?
        args.include?(:bar)
      end
      
      def pop_up?
        args.include?(:pop_up)
      end
      
      def drop_down?
        args.include?(:drop_down)
      end
      
      def text
        @menu_item_proxy&.text
      end
      
      def text=(text_value)
        @menu_item_proxy&.text = text_value
      end
      
      def enabled
        if drop_down?
          menu_item_proxy.enabled
        else
          true
        end
      end
      
      def enabled=(value)
        if drop_down?
          menu_item_proxy.enabled = value
        end
      end
      
      def can_handle_observation_request?(observation_request, super_only: false)
        super_result = super(observation_request)
        if observation_request.start_with?('on_') && !super_result && !super_only
          return menu_item_proxy.can_handle_observation_request?(observation_request)
        else
          super_result
        end
      end
      
      def handle_observation_request(observation_request, block)
        if can_handle_observation_request?(observation_request, super_only: true)
          super
        else
          menu_item_proxy.handle_observation_request(observation_request, block)
        end
      end
      
      def post_initialize_child(child)
        if child && !@children.include?(child)
          if child.is_a?(MenuItemProxy)
            @children << child
          else
            @children << child.menu_item_proxy
          end
        end
      end
      
      def post_add_content
        if bar?
          parent_dom_element.css('position', 'relative')
          parent_dom_element.css('margin-top', '30px')
          parent_dom_element.css('height', '114%')
          render
          `$(#{path}).menu({
            position: { my: "top", at: "bottom" },
            icons: { submenu: "ui-icon-blank" }
          });`
          the_element = dom_element
          the_element.on('mouseenter') do |event|
            if event.page_x.between?(the_element.offset.left, the_element.offset.left + the_element.width) and
               event.page_y.between?(the_element.offset.top, the_element.offset.top + the_element.height)
              `$(#{path}).menu('option', 'position', { my: 'left top', at: 'left bottom' })`
            end
          end
          the_element.on('mouseout') do |event|
            if event.page_x.between?(the_element.offset.left, the_element.offset.left + the_element.width) and
               event.page_y.between?(the_element.offset.top, the_element.offset.top + the_element.height)
              `$(#{path}).menu('option', 'position', { my: 'left top', at: 'left bottom' })`
             else
              `$(#{path}).menu('option', 'position', { my: 'left top', at: 'right top' })`
            end
          end
          minimum_width = children.to_a.map(&:dom_element).map(&:width).map(&:to_f).reduce(:+)
          the_element.css('min-width', minimum_width)
        end
      end
      
      def visible=(value)
        @visible = value
        if @visible
          parent.menu_requested = true
          parent.dom_element.css('position', 'relative')
          render
          dom_element.css('position', 'absolute')
          dom_element.css('left', parent.menu_x - parent.dom_element.offset.left)
          dom_element.css('top', parent.menu_y - parent.dom_element.offset.top)
          parent.menu_requested = false
        else
          close
        end
      end
      
      def render(custom_parent_dom_element: nil, brand_new: false)
        # TODO attach to top nav bar if parent is shell
        # TODO attach listener to parent to display on right click
        if parent.is_a?(MenuProxy) || parent.is_a?(MenuItemProxy) || parent.menu_requested? || parent.is_a?(ShellProxy)
          super(custom_parent_dom_element: custom_parent_dom_element, brand_new: brand_new)
          if root_menu? && !bar?
            `$(#{path}).menu();`
            @close_event_handler = lambda do |event|
              close if event.target != parent.dom_element && event.target.parents('.ui-menu').empty?
            end
            Element['body'].on('click', &@close_event_handler)
          end
        end
      end
      
      def close
        dom_element.remove
        Element['body'].off('click', @close_event_handler)
        @visible = false
      end
      
      def root_menu?
        !parent.is_a?(MenuProxy) && !parent.is_a?(MenuItemProxy)
      end
      
      def root_menu
        the_menu = self
        the_menu = the_menu.parent_menu until the_menu.root_menu?
        the_menu
      end
      
      def parent_menu
        parent.parent unless root_menu?
      end
      
      def element
        'ul'
      end
      
      def dom
        css_class = name
        css_class += ' menu-bar' if bar?
        css_class += ' menu-drop-down' if drop_down?
        css_class += ' menu-pop-up' if pop_up?
        @dom ||= html {
          ul(id: id, class: css_class) {
          }
        }.to_s
      end
    end
    
    MenuBarProxy = MenuProxy
  end
end
