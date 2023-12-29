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

# require 'glimmer/web/event_listener_proxy'
require 'glimmer/web/property_owner'
require 'glimmer/web/listener_proxy'

# TODO implement menu (which delays building it till render using add_content_on_render)

module Glimmer
  module Web
    class ElementProxy
      class << self
        # Factory Method that translates a Glimmer DSL keyword into a ElementProxy object
        def for(keyword, parent, args, block)
          element_type(keyword).new(keyword, parent, args, block)
        end
        
        # returns Ruby proxy class (type) that would handle this keyword
        def element_type(keyword)
          class_name_main = "#{keyword.camelcase(:upper)}Proxy"
          Glimmer::Web::ElementProxy.const_get(class_name_main.to_sym)
        rescue NameError => e
          Glimmer::Web::ElementProxy
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
      
      include Glimmer
      include PropertyOwner
      
      Event = Struct.new(:widget, keyword_init: true)
      
      GLIMMER_ATTRIBUTES = [:parent]
      
      attr_reader :keyword, :parent, :args, :options, :children, :enabled, :foreground, :background, :focus, :removed?, :rendered
      alias rendered? rendered
      
      def initialize(keyword, parent, args, block)
        @keyword = keyword
        @parent = parent
        @options = args.last.is_a?(Hash) ? args.last.symbolize_keys : {}
        @args = args
        @block = block
        @children = []
        @parent&.post_initialize_child(self)
      end
      
      # Executes for the parent of a child that just got added
      def post_initialize_child(child)
        @children << child
        child.render
      end
      
      # Executes for the parent of a child that just got removed
      def post_remove_child(child)
        @children&.delete(child)
      end
      
      # Executes at the closing of a parent widget curly braces after all children/properties have been added/set
      def post_add_content
        # No Op
      end
      
      def css_classes
        dom_element.attr('class').to_s.split
      end
      
      def remove
        remove_all_listeners
        dom_element.remove
        parent&.post_remove_child(self)
#         children.each(:remove) # TODO enable this safely
        @removed = true
#         listeners_for('widget_removed').each {|listener| listener.call(Event.new(widget: self))}
      end
      
      def remove_all_listeners
        listeners.each do |event, event_listeners|
          event_listeners.each(&:unregister)
        end
      end
      
      # Subclasses can override with their own selector
      def selector
        ".#{element_id}"
      end

      # Root element representing widget. Must be overridden by subclasses if different from div
      def element
        keyword
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
      
      def focus=(value)
        @focus = value
        dom_element.focus # TODO consider if a delay or async_exec is needed here
      end
      
      def set_focus
        self.focus = true
      end
      alias setFocus set_focus
      
      def parent_selector
        @parent&.selector
      end

      def parent_dom_element
        if parent_selector
          Document.find(parent_selector)
        else
          # TODO consider moving this to initializer
          options[:parent] ||= 'body'
          Document.find(options[:parent])
        end
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
        unless skip_content_on_render_blocks?
          content_on_render_blocks.each do |content_block|
            content(&content_block)
          end
        end
      end
      alias redraw render
        
      def attach(the_parent_dom_element)
        the_parent_dom_element.append(@dom)
      end
        
      def reattach(old_element)
        old_element.replace_with(@dom)
      end
      
      def add_text_content(text)
        dom_element.append(text.to_s)
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
        @dom
      end
            
      def dom
        # TODO auto-convert known glimmer attributes like parent to data attributes like data-parent
        @dom ||= html {
          send(keyword, html_options) {
            args.first if args.first.is_a?(String)
          }
        }.to_s
      end
      
      def html_options
        body_class = ([name, element_id] + css_classes.to_a).join(' ')
        html_options = options.dup
        GLIMMER_ATTRIBUTES.each do |attribute|
          next unless html_options.include?(attribute)
          data_normalized_attribute = attribute.split('_').join('-')
          html_options["data-#{data_normalized_attribute}"] = html_options.delete(attribute)
        end
        html_options[:class] ||= ''
        html_options[:class] = "#{html_options[:class]} #{body_class}".strip
        html_options
      end
      
      def content(&block)
        Glimmer::DSL::Engine.add_content(self, Glimmer::DSL::Web::ElementExpression.new, keyword, &block)
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
      
      # element ID is used as a css class to identify the element.
      # It is intentionally not set as the actual HTML element ID to let software engineers
      # specify their own IDs if they wanted
      def element_id
        @element_id ||= "element-#{ElementProxy.next_id_number_for(name)}"
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
        Document.find(selector)
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
      
      def listener_selector
        selector
      end
      
      def listener_dom_element
        Document.find(listener_selector)
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
      
      def can_handle_observation_request?(keyword)
        # TODO sort this out for Opal
        keyword = keyword.to_s
        keyword.start_with?('on_')
#         if keyword.start_with?('on_swt_')
#           constant_name = keyword.sub(/^on_swt_/, '')
#           SWTProxy.has_constant?(constant_name)
#         elsif keyword.start_with?('on_')
#           # event = keyword.sub(/^on_/, '')
#           # can_add_listener?(event) || can_handle_drag_observation_request?(keyword) || can_handle_drop_observation_request?(keyword)
#           true # TODO filter by valid listeners only in the future
#         end
      end
      
      def handle_observation_request(keyword, original_event_listener)
#         case keyword
#         when 'on_widget_removed'
#           listeners_for(keyword.sub(/^on_/, '')) << original_event_listener.to_proc
#         else
          handle_javascript_observation_request(keyword, original_event_listener)
#         end
      end
      
      def handle_javascript_observation_request(keyword, original_event_listener)
        listener = ListenerProxy.new(
          element_proxy: self,
          selector: selector,
          dom_element: dom_element,
          event: keyword.sub(/^on_/, ''),
          listener: original_event_listener,
          original_event_listener: original_event_listener
        )
        listener.register
        listeners_for(keyword) << listener
        listener
#         return unless effective_observation_request_to_event_mapping.keys.include?(keyword)
#         event = nil
#         delegate = nil
#         effective_observation_request_to_event_mapping[keyword].to_collection.each do |mapping|
#           observation_requests[keyword] ||= Set.new
#           observation_requests[keyword] << original_event_listener
#           event = mapping[:event]
#           event_handler = mapping[:event_handler]
#           event_element_css_selector = mapping[:event_element_css_selector]
#           potential_event_listener = event_handler&.call(original_event_listener)
#           event_listener = potential_event_listener || original_event_listener
#           async_event_listener = proc do |event|
            ## TODO look into the issue with using async::task.new here. maybe put it in event listener (like not being able to call preventDefault or return false successfully )
            ## maybe consider pushing inside the widget classes instead where needed only or implement universal doit support correctly to bypass this issue
            ## Async::Task.new do
#             @@widget_handling_listener = self
            ## TODO also make sure to disable all widgets for suspension
#             event_listener.call(event) unless dialog_ancestor&.event_handling_suspended?
#             @widget_handling_listener = nil
            ## end
#           end
#           the_listener_dom_element = event_element_css_selector ? Element[event_element_css_selector] : listener_dom_element
#           unless the_listener_dom_element.empty?
#             the_listener_dom_element.on(event, &async_event_listener)
            ## TODO ensure uniqueness of insertion (perhaps adding equals/hash method to event listener proxy)
#
#             event_listener_proxies << EventListenerProxy.new(element_proxy: self, selector: selector, dom_element: the_listener_dom_element, event: event, listener: async_event_listener, original_event_listener: original_event_listener)
#           end
#         end
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
      
      def respond_to_missing?(method_name, include_private = false)
        super(method_name, include_private) ||
          (dom_element && dom_element.length > 0 && Native.call(dom_element, '0').respond_to?(method_name, include_private)) ||
          dom_element.respond_to?(method_name, include_private) ||
          method_name.to_s.start_with?('on_')
      end
      
      def method_missing(method_name, *args, &block)
        if method_name.to_s.start_with?('on_')
          handle_observation_request(method_name, block)
        elsif dom_element.respond_to?(method_name)
          dom_element.send(method_name, *args, &block)
        elsif dom_element && dom_element.length > 0
          begin
            js_args = block.nil? ? args : (args + [block])
            Native.call(dom_element, '0').method_missing(method_name.to_s.camelcase, *js_args)
          rescue Exception
            super(method_name, *args, &block)
          end
        else
          super(method_name, *args, &block)
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
#                 @swt_widget.getBackgroundImage&.remove
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

require 'glimmer/dsl/web/element_expression'
