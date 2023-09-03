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

require 'glimmer/swt/event_listener_proxy'
require 'glimmer/swt/property_owner'
require 'glimmer/swt/swt_proxy'

# TODO implement menu (which delays building it till render using add_content_on_render)

module Glimmer
  module SWT
    class WidgetProxy
      include Glimmer
      include PropertyOwner
            
      Event = Struct.new(:widget, keyword_init: true)
    
      JS_KEY_CODE_TO_SWT_KEY_CODE_MAP = {
        16 => SWTProxy[:shift],
        17 => SWTProxy[:ctrl],
        18 => SWTProxy[:alt],
        37 => SWTProxy[:arrow_left],
        38 => SWTProxy[:arrow_up],
        39 => SWTProxy[:arrow_right],
        40 => SWTProxy[:arrow_down],
      }
      
      JS_LOCATION_TO_SWT_KEY_LOCATION_MAP = {
        0 => SWTProxy[:none],
        1 => SWTProxy[:left],
        2 => SWTProxy[:right],
        3 => SWTProxy[:keypad],
      }
            
      SWT_CURSOR_TO_CSS_CURSOR_MAP = {
        wait: 'wait',
        sizenwse: 'nwse-resize',
        appstarting: 'progress',
        no: 'no-drop',
        sizenesw: 'nesw-resize',
        sizeall: 'all-scroll',
        help: 'help',
        sizee: 'e-resize',
        sizewe: 'ew-resize',
        sizen: 'n-resize',
        sizes: 's-resize',
        sizew: 'w-resize',
        cross: 'crosshair',
        sizese: 'se-resize',
        ibeam: 'text',
        arrow: 'default',
        sizesw: 'sw-resize',
        uparrow: 'alias',
        hand: 'grab',
        sizenw: 'nw-resize',
        sizene: 'ne-resize',
        sizens: 'ns-resize',
      }
      
      attr_reader :parent, :args, :path, :children, :enabled, :foreground, :background, :font, :focus, :disposed?, :rendered, :cursor
      attr_accessor :menu, :menu_requested, :menu_x, :menu_y
      alias isDisposed disposed?
      alias is_disposed disposed?
      alias rendered? rendered
      alias menu_requested? menu_requested
      
      class << self
        # Factory Method that translates a Glimmer DSL keyword into a WidgetProxy object
        def for(keyword, parent, args, block)
          the_widget_class = widget_class(keyword)
          the_widget_class.respond_to?(:create) ? the_widget_class.create(keyword, parent, args, block) : the_widget_class.new(parent, args, block)
        end
        
        def widget_class(keyword)
          class_name_main = "#{keyword.camelcase(:upper)}Proxy"
          Glimmer::SWT.const_get(class_name_main.to_sym)
        rescue => e
          puts "Widget #{keyword} was not found!"
          nil
        end
        
        def widget_exists?(keyword)
          !!widget_class(keyword)
        end
      
        def next_id_number_for(name)
          @max_id_numbers[name] = max_id_number_for(name) + 1
        end
        
        def max_id_number_for(name)
          @max_id_numbers[name] = max_id_numbers[name] || 0
        end
        
        def max_id_numbers
          @max_id_numbers ||= reset_max_id_numbers!
        end
        
        def reset_max_id_numbers!
          @max_id_numbers = {}
        end
        
        def underscored_widget_name(widget_proxy)
          widget_proxy.class.name.split(/::|\./).last.sub(/Proxy$/, '').underscore
        end
        
        def widget_handling_listener
          @@widget_handling_listener
        end
      end
      
      DEFAULT_INITIALIZERS = {
        # TODO remove if built in class initializer is taking care of this
        composite: proc do |composite_proxy|
          if composite_proxy.get_layout.nil?
            the_layout = GridLayoutProxy.new(composite_proxy, [])
            composite_proxy.layout = the_layout
            the_layout.margin_width = 15
            the_layout.margin_height = 15
          end
        end,
#         scrolled_composite: proc do |scrolled_composite|
#           scrolled_composite.expand_horizontal = true
#           scrolled_composite.expand_vertical = true
#         end,
#         table: proc do |table|
#           table.setHeaderVisible(true)
#           table.setLinesVisible(true)
#         end,
        table_column: proc do |table_column_proxy|
          table_column_proxy.width = 80
        end,
#         group: proc do |group_proxy|
#           group_proxy.layout = GridLayoutProxy.new(group_proxy, []) if group.get_layout.nil?
#         end,
      }
      
      def initialize(parent, args, block)
        @parent = parent
        @args = args
        @block = block
        # TODO consider changing children to an array (why is it a Set if order matters?)
        @children = Set.new # TODO consider moving to composite
        @enabled = true if @enabled.nil?
        DEFAULT_INITIALIZERS[self.class.underscored_widget_name(self).to_s.to_sym]&.call(self)
        @parent.post_initialize_child(self) # TODO rename to post_initialize_child to be closer to glimmer-dsl-swt terminology
      end
      
      # Executes for the parent of a child that just got added
      def post_initialize_child(child)
        @children << child
        child.render
      end
      
      # Executes for the parent of a child that just got disposed
      def post_dispose_child(child)
        @children&.delete(child)
      end
      
      # Executes at the closing of a parent widget curly braces after all children/properties have been added/set
      def post_add_content
        if !menu.nil? && !is_a?(MenuProxy) && !is_a?(MenuItemProxy)
          # TODO consider in the future retaining listener registrations to deregister on unsetting of the menu
          on_mouse_move do |mouse_event|
            self.menu_x = mouse_event.x
            self.menu_y = mouse_event.y
          end
          on_mouse_down do |mouse_event|
            if mouse_event.button == 3 # right-click
              menu.visible = true
            end
          end
        end
      end
      
      def set_data(key = nil, value)
        if key.nil?
          @data = value
        else
          swt_data[key] = value
        end
      end
      alias setData set_data
      alias data= set_data
      
      def get_data(key = nil)
        if key.nil?
          @data
        else
          swt_data[key]
        end
      end
      alias getData get_data
      alias data get_data
      
      def swt_data
        @swt_data ||= {}
      end
      
      def css_classes
        dom_element.attr('class').to_s.split
      end
      
      def dispose
        remove_all_listeners
        Document.find(path).remove
        parent&.post_dispose_child(self)
#         children.each(:dispose) # TODO enable this safely
        @disposed = true
        listeners_for('widget_disposed').each {|listener| listener.call(Event.new(widget: self))}
      end
      
      def remove_all_listeners
        effective_observation_request_to_event_mapping.keys.each do |keyword|
          effective_observation_request_to_event_mapping[keyword].to_collection.each do |mapping|
            observation_requests[keyword].to_a.each do |event_listener|
              event = mapping[:event]
              event_handler = mapping[:event_handler]
              event_element_css_selector = mapping[:event_element_css_selector]
              the_listener_dom_element = event_element_css_selector ? Element[event_element_css_selector] : listener_dom_element
              the_listener_dom_element.off(event, event_listener)
              # TODO improve to precisely remove the listeners that were added, no more no less. (or use the event_listener_proxies method instead or in collaboration)
            end
          end
        end
      end
      
      def path
        "#{parent_path} #{element}##{id}.#{name}"
      end
      alias widget_path path # pure path without subchildren modifications

      # Root element representing widget. Must be overridden by subclasses if different from div
      def element
        'div'
      end
      
      def shell
        current_widget = self
        current_widget = current_widget.parent until current_widget.parent.nil?
        current_widget
      end

      def parents
        parents_array = []
        current_widget = self
        until current_widget.parent.nil?
          current_widget = current_widget.parent
          parents_array << current_widget
        end
        parents_array
      end

      def dialog_ancestor
        parents.detect {|p| p.is_a?(DialogProxy)}
      end
      
      def print
        `window.print()`
        true
      end

      def enabled=(value)
        @enabled = value
        dom_element.prop('disabled', !@enabled)
      end
      
      def foreground=(value)
        value = ColorProxy.new(value) if value.is_a?(String)
        @foreground = value
        dom_element.css('color', foreground.to_css) unless foreground.nil?
      end
      
      def background=(value)
        value = ColorProxy.new(value) if value.is_a?(String)
        @background = value
        dom_element.css('background-color', background.to_css) unless background.nil?
      end
      
      def font=(value)
        return if value.nil?
        @font = value.is_a?(FontProxy) ? value : FontProxy.new(self, value)
        dom_element.css('font-family', @font.name) unless @font.nil?
        dom_element.css('font-style', 'italic') if @font&.style == :italic || [@font&.style].flatten.compact.include?(:italic)
        dom_element.css('font-weight', 'bold') if @font&.style == :bold || [@font&.style].flatten.compact.include?(:bold)
        dom_element.css('font-size', "#{@font.height}px") unless @font.nil?
      end
      
      def cursor=(value)
        @cursor = value
        dom_element.css('cursor', css_cursor)
      end
      
      def focus=(value)
        @focus = value
        dom_element.focus # TODO consider if a delay or async_exec is needed here
      end
      
      def set_focus
        self.focus = true
      end
      alias setFocus set_focus
      
      def parent_path
        @parent&.path
      end

      def parent_dom_element
        Document.find(parent_path)
      end
      
      def render(custom_parent_dom_element: nil, brand_new: false)
        the_parent_dom_element = custom_parent_dom_element || parent_dom_element
        old_element = dom_element
        brand_new = @dom.nil? || old_element.empty? || brand_new
        build_dom(layout: !custom_parent_dom_element) # TODO handle custom parent layout by passing parent instead of parent dom element
        if brand_new
          # TODO make a method attach to allow subclasses to override if needed
          attach(the_parent_dom_element)
        else
          reattach(old_element)
        end
        observation_requests&.each do |keyword, event_listener_set|
          event_listener_set.each do |event_listener|
            handle_observation_request(keyword, event_listener)
          end
        end
        children.each do |child|
          child.render
        end
        @rendered = true
        content_on_render_blocks.each { |content_block| content(&content_block) } unless skip_content_on_render_blocks?
      end
      alias redraw render
        
      def attach(the_parent_dom_element)
        the_parent_dom_element.append(@dom)
      end
        
      def reattach(old_element)
        old_element.replace_with(@dom)
      end
      
      def content_on_render_blocks
        @content_on_render_blocks ||= []
      end
      
      def skip_content_on_render_blocks?
        false
      end
      
      def add_content_on_render(&content_block)
        if rendered?
          content_block.call
        else
          content_on_render_blocks << content_block
        end
      end
      
      def build_dom(layout: true)
        # TODO consider passing parent element instead and having table item include a table cell widget only for opal
        @dom = nil
        @dom = dom # TODO unify how to build dom for most widgets based on element, id, and name (class)
        @dom = @parent.get_layout.dom(@dom) if @parent.respond_to?(:layout) && @parent.get_layout
        @dom
      end
      
      def content(&block)
        Glimmer::DSL::Engine.add_content(self, Glimmer::DSL::Opal::WidgetExpression.new, self.class.underscored_widget_name(self), &block)
      end
      
      # Subclasses must override with their own mappings
      def observation_request_to_event_mapping
        {}
      end
      
      def effective_observation_request_to_event_mapping
        default_observation_request_to_event_mapping.merge(observation_request_to_event_mapping)
      end
      
      def default_observation_request_to_event_mapping
        myself = self
        mouse_event_handler = -> (event_listener) {
          -> (event) {
            # TODO generalize this solution to all widgets that support key presses
            event.define_singleton_method(:widget) {myself}
            event.define_singleton_method(:button, &event.method(:which))
            event.define_singleton_method(:count) {1} # TODO support double-click count of 2 in the future by using ondblclick
            event.define_singleton_method(:x, &event.method(:page_x))
            event.define_singleton_method(:y, &event.method(:page_y))
            doit = true
            event.define_singleton_method(:doit=) do |value|
              doit = value
            end
            event.define_singleton_method(:doit) { doit }
            
            if event.which == 1
#               event.prevent # TODO consider if this is needed
              event_listener.call(event)
            end
            
            # TODO Imlement doit properly for all different kinds of events
#             unless doit
#               event.prevent
#               event.stop
#               event.stop_immediate
#             end
          }
        }
        mouse_move_event_handler = -> (event_listener) {
          -> (event) {
            # TODO generalize this solution to all widgets that support key presses
            event.define_singleton_method(:widget) {myself}
            event.define_singleton_method(:button, &event.method(:which))
            event.define_singleton_method(:count) {1} # TODO support double-click count of 2 in the future by using ondblclick
            event.define_singleton_method(:x, &event.method(:page_x))
            event.define_singleton_method(:y, &event.method(:page_y))
            doit = true
            event.define_singleton_method(:doit=) do |value|
              doit = value
            end
            event.define_singleton_method(:doit) { doit }
            
            event_listener.call(event)
            
            # TODO Imlement doit properly for all different kinds of events
#             unless doit
#               event.prevent
#               event.stop
#               event.stop_immediate
#             end
          }
        }
        context_menu_handler = -> (event_listener) {
          -> (event) {
            # TODO generalize this solution to all widgets that support key presses
            event.define_singleton_method(:widget) {myself}
            event.define_singleton_method(:button, &event.method(:which))
            event.define_singleton_method(:count) {1} # TODO support double-click count of 2 in the future by using ondblclick
            event.define_singleton_method(:x, &event.method(:page_x))
            event.define_singleton_method(:y, &event.method(:page_y))
            doit = true
            event.define_singleton_method(:doit=) do |value|
              doit = value
            end
            event.define_singleton_method(:doit) { doit }
            
            if event.which == 3
              event.prevent
              event_listener.call(event)
            end
            # TODO Imlement doit properly for all different kinds of events
#             unless doit
#               event.prevent
#               event.stop
#               event.stop_immediate
#             end
          }
        }
        {
          'on_focus_gained' => {
            event: 'focus',
          },
          'on_focus_lost' => {
            event: 'blur',
          },
          'on_mouse_move' => [
            {
              event: 'mousemove',
              event_handler: mouse_move_event_handler,
            },
          ],
          'on_mouse_up' => [
            {
              event: 'mouseup',
              event_handler: mouse_event_handler,
            },
            {
              event: 'contextmenu',
              event_handler: context_menu_handler,
            },
          ],
          'on_mouse_down' => [
            {
              event: 'mousedown',
              event_handler: mouse_event_handler,
            },
            {
              event: 'contextmenu',
              event_handler: context_menu_handler,
            },
          ],
          'on_swt_mouseup' => [
            {
              event: 'mouseup',
              event_handler: mouse_event_handler,
            },
            {
              event: 'contextmenu',
              event_handler: context_menu_handler,
            },
          ],
          'on_swt_mousedown' => [
            {
              event: 'mousedown',
              event_handler: mouse_event_handler,
            },
            {
              event: 'contextmenu',
              event_handler: context_menu_handler,
            },
          ],
          'on_key_pressed' => {
            event: 'keypress',
            event_handler: -> (event_listener) {
              -> (event) {
                event.define_singleton_method(:widget) {myself}
                event.define_singleton_method(:keyLocation) do
                  location = `#{event.to_n}.originalEvent.location`
                  JS_LOCATION_TO_SWT_KEY_LOCATION_MAP[location] || location
                end
                event.define_singleton_method(:key_location, &event.method(:keyLocation))
                event.define_singleton_method(:keyCode) {
                  JS_KEY_CODE_TO_SWT_KEY_CODE_MAP[event.which] || event.which
                }
                event.define_singleton_method(:key_code, &event.method(:keyCode))
                event.define_singleton_method(:character) {event.which.chr}
                event.define_singleton_method(:stateMask) do
                  state_mask = 0
                  state_mask |= SWTProxy[:alt] if event.alt_key
                  state_mask |= SWTProxy[:ctrl] if event.ctrl_key
                  state_mask |= SWTProxy[:shift] if event.shift_key
                  state_mask |= SWTProxy[:command] if event.meta_key
                  state_mask
                end
                event.define_singleton_method(:state_mask, &event.method(:stateMask))
                doit = true
                event.define_singleton_method(:doit=) do |value|
                  doit = value
                end
                event.define_singleton_method(:doit) { doit }
                event_listener.call(event)
                
                  # TODO Fix doit false, it's not stopping input
                unless doit
                  event.prevent
                  event.prevent_default
                  event.stop_propagation
                  event.stop_immediate_propagation
                end
                
                doit
              }
            }          },
          'on_key_released' => {
            event: 'keyup',
            event_handler: -> (event_listener) {
              -> (event) {
                event.define_singleton_method(:keyLocation) do
                  location = `#{event.to_n}.originalEvent.location`
                  JS_LOCATION_TO_SWT_KEY_LOCATION_MAP[location] || location
                end
                event.define_singleton_method(:key_location, &event.method(:keyLocation))
                event.define_singleton_method(:widget) {myself}
                event.define_singleton_method(:keyCode) {
                  JS_KEY_CODE_TO_SWT_KEY_CODE_MAP[event.which] || event.which
                }
                event.define_singleton_method(:key_code, &event.method(:keyCode))
                event.define_singleton_method(:character) {event.which.chr}
                event.define_singleton_method(:stateMask) do
                  state_mask = 0
                  state_mask |= SWTProxy[:alt] if event.alt_key
                  state_mask |= SWTProxy[:ctrl] if event.ctrl_key
                  state_mask |= SWTProxy[:shift] if event.shift_key
                  state_mask |= SWTProxy[:command] if event.meta_key
                  state_mask
                end
                event.define_singleton_method(:state_mask, &event.method(:stateMask))
                doit = true
                event.define_singleton_method(:doit=) do |value|
                  doit = value
                end
                event.define_singleton_method(:doit) { doit }
                event_listener.call(event)
                
                  # TODO Fix doit false, it's not stopping input
                unless doit
                  event.prevent
                  event.prevent_default
                  event.stop_propagation
                  event.stop_immediate_propagation
                end
                
                doit
              }
            }
          },
          'on_swt_keydown' => [
            {
              event: 'keypress',
              event_handler: -> (event_listener) {
                -> (event) {
                  event.define_singleton_method(:keyLocation) do
                    location = `#{event.to_n}.originalEvent.location`
                    JS_LOCATION_TO_SWT_KEY_LOCATION_MAP[location] || location
                  end
                  event.define_singleton_method(:key_location, &event.method(:keyLocation))
                  event.define_singleton_method(:keyCode) {
                    JS_KEY_CODE_TO_SWT_KEY_CODE_MAP[event.which] || event.which
                  }
                  event.define_singleton_method(:key_code, &event.method(:keyCode))
                  event.define_singleton_method(:widget) {myself}
                  event.define_singleton_method(:character) {event.which.chr}
                  event.define_singleton_method(:stateMask) do
                    state_mask = 0
                    state_mask |= SWTProxy[:alt] if event.alt_key
                    state_mask |= SWTProxy[:ctrl] if event.ctrl_key
                    state_mask |= SWTProxy[:shift] if event.shift_key
                    state_mask |= SWTProxy[:command] if event.meta_key
                    state_mask
                  end
                  event.define_singleton_method(:state_mask, &event.method(:stateMask))
                  doit = true
                  event.define_singleton_method(:doit=) do |value|
                    doit = value
                  end
                  event.define_singleton_method(:doit) { doit }
                  event_listener.call(event)
                  
                    # TODO Fix doit false, it's not stopping input
                  unless doit
                    event.prevent
                    event.prevent_default
                    event.stop_propagation
                    event.stop_immediate_propagation
                  end
                  
                  doit
                }
              }
            },
            {
              event: 'keydown',
              event_handler: -> (event_listener) {
                -> (event) {
                  event.define_singleton_method(:keyLocation) do
                    location = `#{event.to_n}.originalEvent.location`
                    JS_LOCATION_TO_SWT_KEY_LOCATION_MAP[location] || location
                  end
                  event.define_singleton_method(:key_location, &event.method(:keyLocation))
                  event.define_singleton_method(:keyCode) {
                    JS_KEY_CODE_TO_SWT_KEY_CODE_MAP[event.which] || event.which
                  }
                  event.define_singleton_method(:key_code, &event.method(:keyCode))
                  event.define_singleton_method(:widget) {myself}
                  event.define_singleton_method(:character) {event.which.chr}
                  event.define_singleton_method(:stateMask) do
                    state_mask = 0
                    state_mask |= SWTProxy[:alt] if event.alt_key
                    state_mask |= SWTProxy[:ctrl] if event.ctrl_key
                    state_mask |= SWTProxy[:shift] if event.shift_key
                    state_mask |= SWTProxy[:command] if event.meta_key
                    state_mask
                  end
                  event.define_singleton_method(:state_mask, &event.method(:stateMask))
                  doit = true
                  event.define_singleton_method(:doit=) do |value|
                    doit = value
                  end
                  event.define_singleton_method(:doit) { doit }
                  event_listener.call(event) if event.which != 13 && (event.which == 127 || event.which <= 40)
                  
                    # TODO Fix doit false, it's not stopping input
                  unless doit
                    event.prevent
                    event.prevent_default
                    event.stop_propagation
                    event.stop_immediate_propagation
                  end
                  doit
                }
              }
            }
          ],
          'on_swt_keyup' => {
            event: 'keyup',
            event_handler: -> (event_listener) {
              -> (event) {
                event.define_singleton_method(:keyLocation) do
                  location = `#{event.to_n}.originalEvent.location`
                  JS_LOCATION_TO_SWT_KEY_LOCATION_MAP[location] || location
                end
                event.define_singleton_method(:key_location, &event.method(:keyLocation))
                event.define_singleton_method(:widget) {myself}
                event.define_singleton_method(:keyCode) {
                  JS_KEY_CODE_TO_SWT_KEY_CODE_MAP[event.which] || event.which
                }
                event.define_singleton_method(:key_code, &event.method(:keyCode))
                event.define_singleton_method(:character) {event.which.chr}
                event.define_singleton_method(:stateMask) do
                  state_mask = 0
                  state_mask |= SWTProxy[:alt] if event.alt_key
                  state_mask |= SWTProxy[:ctrl] if event.ctrl_key
                  state_mask |= SWTProxy[:shift] if event.shift_key
                  state_mask |= SWTProxy[:command] if event.meta_key
                  state_mask
                end
                event.define_singleton_method(:state_mask, &event.method(:stateMask))
                doit = true
                event.define_singleton_method(:doit=) do |value|
                  doit = value
                end
                event.define_singleton_method(:doit) { doit }
                event_listener.call(event)
                
                  # TODO Fix doit false, it's not stopping input
                unless doit
                  event.prevent
                  event.prevent_default
                  event.stop_propagation
                  event.stop_immediate_propagation
                end
                
                doit
              }
            }
          },
        }
      end
      
      def name
        self.class.name.split('::').last.underscore.sub(/_proxy$/, '').gsub('_', '-')
      end
      
      def id
        @id ||= "#{name}-#{WidgetProxy.next_id_number_for(name)}"
      end
            
      # Sets id explicitly. Useful in cases of wanting to maintain a stable id
      def id=(value)
        @id = value
      end
            
      # Subclasses can override with their own selector
      def selector
        "#{name}##{id}"
      end
      
      def add_css_class(css_class)
        dom_element.add_class(css_class)
      end
      
      def add_css_classes(css_classes_to_add)
        css_classes_to_add.each {|css_class| add_css_class(css_class)}
      end
      
      def remove_css_class(css_class)
        dom_element.remove_class(css_class)
      end
      
      def remove_css_classes(css_classes_to_remove)
        css_classes_to_remove.each {|css_class| remove_css_class(css_class)}
      end
      
      def clear_css_classes
        css_classes.each {|css_class| remove_css_class(css_class)}
      end
      
      def has_style?(symbol)
        @args.include?(symbol) # not a very solid implementation. Bring SWT constants eventually
      end
      
      def dom_element
        # TODO consider making this pick an element in relation to its parent, allowing unhooked dom elements to be built if needed (unhooked to the visible page dom)
        Document.find(path)
      end
      
      # TODO consider adding a default #dom method implementation for the common case, automatically relying on #element and other methods to build the dom html
      
      def style_element
        style_element_id = "#{id}-style"
        style_element_selector = "style##{style_element_id}"
        element = dom_element.find(style_element_selector)
        if element.empty?
          new_element = Element.new(:style)
          new_element.attr('id', style_element_id)
          new_element.attr('class', "#{name.gsub('_', '-')}-instance-style widget-instance-style")
          dom_element.prepend(new_element)
          element = dom_element.find(style_element_selector)
        end
        element
      end
      
      def listener_path
        path
      end
      
      def listener_dom_element
        Document.find(listener_path)
      end
      
      def observation_requests
        @observation_requests ||= {}
      end
      
      def event_listener_proxies
        @event_listener_proxies ||= []
      end
      
      def suspend_event_handling
        @event_handling_suspended = true
      end
      
      def resume_event_handling
        @event_handling_suspended = false
      end
      
      def event_handling_suspended?
        @event_handling_suspended
      end
      
      def listeners
        @listeners ||= {}
      end
      
      def listeners_for(listener_event)
        listeners[listener_event.to_s] ||= []
      end
      
      def can_handle_observation_request?(observation_request)
        # TODO sort this out for Opal
        observation_request = observation_request.to_s
        if observation_request.start_with?('on_swt_')
          constant_name = observation_request.sub(/^on_swt_/, '')
          SWTProxy.has_constant?(constant_name)
        elsif observation_request.start_with?('on_')
#           event = observation_request.sub(/^on_/, '')
#           can_add_listener?(event) || can_handle_drag_observation_request?(observation_request) || can_handle_drop_observation_request?(observation_request)
          true # TODO filter by valid listeners only in the future
        end
      end
      
      def handle_observation_request(keyword, original_event_listener)
        case keyword
        when 'on_widget_disposed'
          listeners_for(keyword.sub(/^on_/, '')) << original_event_listener.to_proc
        else
          handle_javascript_observation_request(keyword, original_event_listener)
        end
      end
      
      def handle_javascript_observation_request(keyword, original_event_listener)
        return unless effective_observation_request_to_event_mapping.keys.include?(keyword)
        event = nil
        delegate = nil
        effective_observation_request_to_event_mapping[keyword].to_collection.each do |mapping|
          observation_requests[keyword] ||= Set.new
          observation_requests[keyword] << original_event_listener
          event = mapping[:event]
          event_handler = mapping[:event_handler]
          event_element_css_selector = mapping[:event_element_css_selector]
          potential_event_listener = event_handler&.call(original_event_listener)
          event_listener = potential_event_listener || original_event_listener
          async_event_listener = proc do |event|
            # TODO look into the issue with using async::task.new here. maybe put it in event listener (like not being able to call preventDefault or return false successfully )
            # maybe consider pushing inside the widget classes instead where needed only or implement universal doit support correctly to bypass this issue
#             Async::Task.new do
            @@widget_handling_listener = self
            # TODO also make sure to disable all widgets for suspension
            event_listener.call(event) unless dialog_ancestor&.event_handling_suspended?
            @widget_handling_listener = nil
#             end
          end
          the_listener_dom_element = event_element_css_selector ? Element[event_element_css_selector] : listener_dom_element
          unless the_listener_dom_element.empty?
            the_listener_dom_element.on(event, &async_event_listener)
            # TODO ensure uniqueness of insertion (perhaps adding equals/hash method to event listener proxy)
            
            event_listener_proxies << EventListenerProxy.new(element_proxy: self, selector: selector, dom_element: the_listener_dom_element, event: event, listener: async_event_listener, original_event_listener: original_event_listener)
          end
        end
      end
      
      def remove_event_listener_proxies
        event_listener_proxies.each do |event_listener_proxy|
          event_listener_proxy.unregister
        end
        event_listener_proxies.clear
      end
      
      def add_observer(observer, property_name)
        property_listener_installers = self.class&.ancestors&.to_a.map {|ancestor| widget_property_listener_installers[ancestor]}.compact
        widget_listener_installers = property_listener_installers.map{|installer| installer[property_name.to_s.to_sym]}.compact if !property_listener_installers.empty?
        widget_listener_installers.to_a.each do |widget_listener_installer|
          widget_listener_installer.call(observer)
        end
      end
      
      def set_attribute(attribute_name, *args)
        apply_property_type_converters(attribute_name, args)
        super(attribute_name, *args) # PropertyOwner
      end
      
      def method_missing(method, *args, &block)
        if method.to_s.start_with?('on_')
          handle_observation_request(method, block)
        else
          super(method, *args, &block)
        end
      end
      
      def swt_widget
        # only added for compatibility/adaptibility with Glimmer DSL for SWT
        self
      end
      
      def apply_property_type_converters(attribute_name, args)
        if args.count == 1
          value = args.first
          converter = property_type_converters[attribute_name.to_sym]
          args[0] = converter.call(value) if converter
        end
#         if args.count == 1 && args.first.is_a?(ColorProxy)
#           g_color = args.first
#           args[0] = g_color.swt_color
#         end
      end
      
      def property_type_converters
        color_converter = proc do |value|
          if value.is_a?(Symbol) || value.is_a?(String)
            ColorProxy.new(value)
          else
            value
          end
        end
        @property_type_converters ||= {
          :background => color_converter,
#           :background_image => proc do |value|
#             if value.is_a?(String)
#               if value.start_with?('uri:classloader')
#                 value = value.sub(/^uri\:classloader\:\//, '')
#                 object = java.lang.Object.new
#                 value = object.java_class.resource_as_stream(value)
#                 value = java.io.BufferedInputStream.new(value)
#               end
#               image_data = ImageData.new(value)
#               on_event_Resize do |resize_event|
#                 new_image_data = image_data.scaledTo(@swt_widget.getSize.x, @swt_widget.getSize.y)
#                 @swt_widget.getBackgroundImage&.dispose
#                 @swt_widget.setBackgroundImage(Image.new(@swt_widget.getDisplay, new_image_data))
#               end
#               Image.new(@swt_widget.getDisplay, image_data)
#             else
#               value
#             end
#           end,
          :foreground => color_converter,
#           :font => proc do |value|
#             if value.is_a?(Hash)
#               font_properties = value
#               FontProxy.new(self, font_properties).swt_font
#             else
#               value
#             end
#           end,
          :text => proc do |value|
#             if swt_widget.is_a?(Browser)
#               value.to_s
#             else
              value.to_s
#             end
          end,
#           :visible => proc do |value|
#             !!value
#           end,
        }
      end
      
      def widget_property_listener_installers
        @swt_widget_property_listener_installers ||= {
#           WidgetProxy => {
#             :focus => proc do |observer|
#               on_focus_gained { |focus_event|
#                 observer.call(true)
#               }
#               on_focus_lost { |focus_event|
#                 observer.call(false)
#               }
#             end,
#           },
          MenuItemProxy => {
            :selection => proc do |observer|
              on_widget_selected { |selection_event|
                # TODO look into validity of this and perhaps move toggle logic to MenuItemProxy
                if check?
                  observer.call(!selection)
                else
                  observer.call(selection)
                end
              }
            end
          },
          ScaleProxy => {
            :selection => proc do |observer|
              on_widget_selected { |selection_event|
                observer.call(selection)
              }
            end
          },
          SliderProxy => {
            :selection => proc do |observer|
              on_widget_selected { |selection_event|
                observer.call(selection)
              }
            end
          },
          SpinnerProxy => {
            :selection => proc do |observer|
              on_widget_selected { |selection_event|
                observer.call(selection)
              }
            end
          },
          TextProxy => {
            :text => proc do |observer|
              on_modify_text { |modify_event|
                observer.call(text)
              }
            end,
#             :caret_position => proc do |observer|
#               on_event_keydown { |event|
#                 observer.call(getCaretPosition)
#               }
#               on_event_keyup { |event|
#                 observer.call(getCaretPosition)
#               }
#               on_event_mousedown { |event|
#                 observer.call(getCaretPosition)
#               }
#               on_event_mouseup { |event|
#                 observer.call(getCaretPosition)
#               }
#             end,
#             :selection => proc do |observer|
#               on_event_keydown { |event|
#                 observer.call(getSelection)
#               }
#               on_event_keyup { |event|
#                 observer.call(getSelection)
#               }
#               on_event_mousedown { |event|
#                 observer.call(getSelection)
#               }
#               on_event_mouseup { |event|
#                 observer.call(getSelection)
#               }
#             end,
#             :selection_count => proc do |observer|
#               on_event_keydown { |event|
#                 observer.call(getSelectionCount)
#               }
#               on_event_keyup { |event|
#                 observer.call(getSelectionCount)
#               }
#               on_event_mousedown { |event|
#                 observer.call(getSelectionCount)
#               }
#               on_event_mouseup { |event|
#                 observer.call(getSelectionCount)
#               }
#             end,
#             :top_index => proc do |observer|
#               @last_top_index = getTopIndex
#               on_paint_control { |event|
#                 if getTopIndex != @last_top_index
#                   @last_top_index = getTopIndex
#                   observer.call(@last_top_index)
#                 end
#               }
#             end,
          },
#           Java::OrgEclipseSwtCustom::StyledText => {
#             :text => proc do |observer|
#               on_modify_text { |modify_event|
#                 observer.call(getText)
#               }
#             end,
#           },
          DateTimeProxy => {
            :date_time => proc do |observer|
              on_widget_selected { |selection_event|
                observer.call(date_time)
              }
            end
          },
          RadioProxy => { #radio?
            :selection => proc do |observer|
              on_widget_selected { |selection_event|
                observer.call(selection)
              }
            end
          },
          TableProxy => {
            :selection => proc do |observer|
              on_widget_selected { |selection_event|
                observer.call(selection_event.table_item.get_data)  # TODO ensure selection doesn't conflict with editing
              }
            end,
          },
#           Java::OrgEclipseSwtWidgets::MenuItem => {
#             :selection => proc do |observer|
#               on_widget_selected { |selection_event|
#                 observer.call(getSelection)
#               }
#             end
#           },
        }
      end
      
      private
      
      def css_cursor
        SWT_CURSOR_TO_CSS_CURSOR_MAP[@cursor]
      end
      
    end
  end
end

require 'glimmer/swt/display_proxy'
require 'glimmer/swt/browser_proxy'
require 'glimmer/swt/button_proxy'
require 'glimmer/swt/arrow_proxy'
require 'glimmer/swt/combo_proxy'
require 'glimmer/swt/c_combo_proxy'
require 'glimmer/swt/checkbox_proxy'
require 'glimmer/swt/composite_proxy'
require 'glimmer/swt/canvas_proxy'
require 'glimmer/swt/date_time_proxy'
require 'glimmer/swt/group_proxy'
require 'glimmer/swt/label_proxy'
require 'glimmer/swt/list_proxy'
require 'glimmer/swt/menu_item_proxy'
require 'glimmer/swt/menu_proxy'
require 'glimmer/swt/radio_proxy'
require 'glimmer/swt/tab_folder_proxy'
require 'glimmer/swt/tab_item_proxy'
require 'glimmer/swt/c_tab_folder_proxy'
require 'glimmer/swt/c_tab_item_proxy'
require 'glimmer/swt/table_column_proxy'
require 'glimmer/swt/table_item_proxy'
require 'glimmer/swt/table_proxy'
require 'glimmer/swt/text_proxy'
require 'glimmer/swt/progress_bar_proxy'
require 'glimmer/swt/radio_proxy'
require 'glimmer/swt/scale_proxy'
require 'glimmer/swt/scrolled_composite_proxy'
require 'glimmer/swt/slider_proxy'
require 'glimmer/swt/spinner_proxy'
require 'glimmer/swt/styled_text_proxy'

require 'glimmer/dsl/opal/widget_expression'
