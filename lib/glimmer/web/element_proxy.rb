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

require 'glimmer/web/listener_proxy'

module Glimmer
  module Web
    class ElementProxy
      class << self
        def keyword_supported?(keyword)
          ELEMENT_KEYWORDS.include?(keyword.to_s)
        end
      
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
      
      Event = Struct.new(:widget, keyword_init: true)
      
      ELEMENT_KEYWORDS = [
        "a", "abbr", "acronym", "address", "applet", "area", "article", "aside", "audio", "b",
        "base", "basefont", "bdi", "bdo", "bgsound", "big", "blink", "blockquote", "body", "br",
        "button", "canvas", "caption", "center", "cite", "code", "col", "colgroup", "content", "data",
        "datalist", "dd", "decorator", "del", "details", "dfn", "dir", "div", "dl", "dt",
        "element", "em", "embed", "fieldset", "figcaption", "figure", "font", "footer", "form", "frame",
        "frameset", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup",
        "hr", "html", "i", "iframe", "img", "input", "ins", "isindex", "kbd", "keygen",
        "label", "legend", "li", "link", "listing", "main", "map", "mark", "marquee", "menu",
        "menuitem", "meta", "meter", "nav", "nobr", "noframes", "noscript", "object", "ol", "optgroup",
        "option", "output", "p", "param", "plaintext", "pre", "progress", "q", "rp", "rt",
        "ruby", "s", "samp", "script", "section", "select", "shadow", "small", "source", "spacer",
        "span", "strike", "strong", "style", "sub", "summary", "sup", "table", "tbody", "td",
        "template", "textarea", "tfoot", "th", "thead", "time", "title", "tr", "track", "tt",
        "u", "ul", "var", "video", "wbr", "xmp",
      ]

      GLIMMER_ATTRIBUTES = [:parent]
      FORMAT_DATETIME = '%Y-%m-%dT%H:%M'
      FORMAT_DATE = '%Y-%m-%d'
      FORMAT_TIME = '%H:%M'
      REGEX_FORMAT_DATETIME = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/
      REGEX_FORMAT_DATE = /^\d{4}-\d{2}-\d{2}$/
      REGEX_FORMAT_TIME = /^\d{2}:\d{2}$/
      
      attr_reader :keyword, :parent, :args, :options, :children, :enabled, :foreground, :background, :removed?, :rendered
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
        @children.delete(child)
      end
      
      # Executes at the closing of a parent widget curly braces after all children/properties have been added/set
      def post_add_content
        # No Op
      end
      
      def css_classes
        dom_element.attr('class').to_s.split
      end
      
      def remove
        @children.dup.each do |child|
          child.remove
        end
        remove_all_listeners
        dom_element.remove
        parent&.post_remove_child(self)
        @removed = true
#         listeners_for('widget_removed').each {|listener| listener.call(Event.new(widget: self))}
      end
      
      def remove_all_listeners
        listeners.each do |event, event_listeners|
          event_listeners.dup.each(&:unregister)
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
      
      def parent_selector
        @parent&.selector
      end

      def parent_dom_element
        if parent_selector
          Document.find(parent_selector)
        else
          # TODO consider moving this to initializer
          options[:parent] ||= 'body'
          the_element = Document.find(options[:parent])
          the_element = Document.find('body') if the_element.length == 0
          the_element
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
      alias rerender render
        
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
        keyword.start_with?('on')
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
          element: self,
          selector: selector,
          dom_element: dom_element,
          event_attribute: keyword,
          listener: original_event_listener,
          original_event_listener: original_event_listener
        )
        listener.register
        listeners_for(keyword) << listener
        listener
      end
      
      def remove_event_listener_proxies
        event_listener_proxies.each do |event_listener_proxy|
          event_listener_proxy.unregister
        end
        event_listener_proxies.clear
      end
      
      def data_bind(property, model_binding)
        element_binding_translator = value_converters_for_input_type(type)[:model_to_view]
        element_binding_parameters = [self, property, element_binding_translator]
        element_binding = DataBinding::ElementBinding.new(*element_binding_parameters)
        element_binding.call(model_binding.evaluate_property)
        #TODO make this options observer dependent and all similar observers in element specific data binding handlers
        element_binding.observe(model_binding)
        unless model_binding.binding_options[:read_only]
          # TODO add guards against nil cases for hash below
          listener_keyword = data_binding_listener_for_element_and_property(keyword, property)
          if listener_keyword
            data_binding_read_listener = lambda do |event|
              view_property_value = send(property)
              converted_view_property_value = value_converters_for_input_type(type)[:view_to_model].call(view_property_value, model_binding.evaluate_property)
              model_binding.call(converted_view_property_value)
            end
            handle_observation_request(listener_keyword, data_binding_read_listener)
          end
        end
      end
      
      # Data-binds the generation of nested content to a model/property (in binding args)
      # consider providing an option to avoid initial rendering without any changes happening
      def bind_content(*binding_args, &content_block)
        # TODO in the future, consider optimizing code by diffing content if that makes sense
        content_binding_work = proc do |*values|
          children.dup.each { |child| child.remove }
          content(&content_block)
        end
        content_binding_observer = Glimmer::DataBinding::Observer.proc(&content_binding_work)
        content_binding_observer.observe(*binding_args)
        content_binding_work.call # TODO inspect if we need to pass args here (from observed attributes) [but it's simpler not to pass anything at first]
      end
      
      def respond_to_missing?(method_name, include_private = false)
        # TODO consider doing more correct checking of availability of properties/methods using native `` ticks
        property_name = property_name_for(method_name)
        super(method_name, include_private) ||
          (dom_element && dom_element.length > 0 && Native.call(dom_element, '0').respond_to?(method_name.to_s.camelcase, include_private)) ||
          dom_element.respond_to?(method_name, include_private) ||
          (!dom_element.prop(property_name).nil? && !dom_element.prop(property_name).is_a?(Proc)) ||
          method_name.to_s.start_with?('on_')
      end
      
      def method_missing(method_name, *args, &block)
        # TODO consider doing more correct checking of availability of properties/methods using native `` ticks
        property_name = property_name_for(method_name)
        if method_name.to_s.start_with?('on_')
          handle_observation_request(method_name, block)
        elsif dom_element.respond_to?(method_name)
          dom_element.send(method_name, *args, &block)
        elsif !dom_element.prop(property_name).nil? && !dom_element.prop(property_name).is_a?(Proc)
          if method_name.end_with?('=')
            dom_element.prop(property_name, *args)
          else
            dom_element.prop(property_name)
          end
        elsif dom_element && dom_element.length > 0
          begin
            js_args = block.nil? ? args : (args + [block])
            Native.call(dom_element, '0').method_missing(method_name.to_s.camelcase, *js_args)
          rescue Exception => e
            super(method_name, *args, &block)
          end
        else
          super(method_name, *args, &block)
        end
      end
      
      def property_name_for(method_name)
        method_name.end_with?('=') ? method_name.to_s[0...-1].camelcase : method_name.to_s.camelcase
      end
      
      def swt_widget
        # only added for compatibility/adaptibility with Glimmer DSL for SWT
        self
      end
      
      def data_binding_listener_for_element_and_property(element_keyword, property)
        data_binding_property_listener_map_for_element(element_keyword)[property]
      end
      
      def data_binding_property_listener_map_for_element(element_keyword)
        data_binding_element_keyword_to_property_listener_map[element_keyword] || {}
      end
      
      def data_binding_element_keyword_to_property_listener_map
        @data_binding_element_keyword_to_property_listener_map ||= {
          'input' => {
            'value' => 'oninput',
            'checked' => 'oninput',
          },
          'select' => {
            'value' => 'onchange',
          },
          'textarea' => {
            'value' => 'oninput',
          },
        }
      end
      
      def value_converters_for_input_type(input_type)
        input_value_converters[input_type] || {model_to_view: ->(value, old_value) {value}, view_to_model: ->(value, old_value) {value}}
      end
      
      def input_value_converters
        @input_value_converters ||= {
          'number' => {
            model_to_view: -> (value, old_value) { value.to_s },
            view_to_model: -> (value, old_value) {
              value.include?('.') ? value.to_f : value.to_i
            },
          },
          'range' => {
            model_to_view: -> (value, old_value) { value.to_s },
            view_to_model: -> (value, old_value) {
              value.include?('.') ? value.to_f : value.to_i
            },
          },
          'datetime-local' => {
            model_to_view: -> (value, old_value) {
              if value.respond_to?(:strftime)
                value.strftime(FORMAT_DATETIME)
              elsif value.is_a?(String) && valid_js_date_string?(value)
                value
              else
                old_value
              end
            },
            view_to_model: -> (value, old_value) {
              if value.to_s.empty?
                nil
              else
                date = Native(`new Date(Date.parse(#{value}))`)
                year = Native.call(date, 'getFullYear')
                month = Native.call(date, 'getMonth') + 1
                day = Native.call(date, 'getDate')
                hour = Native.call(date, 'getHours')
                minute = Native.call(date, 'getMinutes')
                Time.new(year, month, day, hour, minute)
              end
            },
          },
          'date' => {
            model_to_view: -> (value, old_value) {
              if value.respond_to?(:strftime)
                value.strftime(FORMAT_DATE)
              elsif value.is_a?(String) && valid_js_date_string?(value)
                value
              else
                old_value
              end
            },
            view_to_model: -> (value, old_value) {
              if value.to_s.empty?
                nil
              else
                year, month, day = value.split('-')
                if old_value
                  Time.new(year, month, day, old_value.hour, old_value.min)
                else
                  Time.new(year, month, day)
                end
              end
            },
          },
          'time' => {
            model_to_view: -> (value, old_value) {
              if value.respond_to?(:strftime)
                value.strftime(FORMAT_TIME)
              elsif value.is_a?(String) && valid_js_date_string?(value)
                value
              else
                old_value
              end
            },
            view_to_model: -> (value, old_value) {
              if value.to_s.empty?
                nil
              else
                hour, minute = value.split(':')
                if old_value
                  Time.new(old_value.year, old_value.month, old_value.day, hour, minute)
                else
                  now = Time.now
                  Time.new(now.year, now.month, now.day, hour, minute)
                end
              end
            },
          },
        }
      end
      
      private
      
      def valid_js_date_string?(string)
        [REGEX_FORMAT_DATETIME, REGEX_FORMAT_DATE, REGEX_FORMAT_TIME].any? do |format|
          string.match(format)
        end
      end
      
      def css_cursor
        SWT_CURSOR_TO_CSS_CURSOR_MAP[@cursor]
      end
      
    end
  end
end

require 'glimmer/dsl/web/element_expression'
