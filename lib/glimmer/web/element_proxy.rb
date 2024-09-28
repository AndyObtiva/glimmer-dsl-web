# backtick_javascript: true

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
      
        def html_keyword_supported?(keyword)
          HTML_ELEMENT_KEYWORDS.include?(keyword.to_s)
        end
      
        def svg_keyword_supported?(keyword)
          SVG_ELEMENT_KEYWORDS.include?(keyword.to_s)
        end
      
        # NOTE: Avoid using this method until we start supporting ElementProxy subclasses
        # in which case, we must cache them to avoid the slow performance of element_type
        # Factory Method that translates a Glimmer DSL keyword into a ElementProxy object
        def for(keyword, parent, args, block)
          element_type(keyword).new(keyword, parent, args, block)
        end
        
        # NOTE: Avoid using this method for now as it has slow performance
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
        
        def render_html(element, attributes, content = nil)
          attributes = attributes.reduce('') do |output, option_pair|
            attribute, value = option_pair
            value = value.to_s.sub('"', '&quot;').sub("'", '&apos;')
            output += " #{attribute}=\"#{value}\""
          end
          if content.nil?
            "<#{element}#{attributes} />"
          else
            "<#{element}#{attributes}>#{content}</#{element}>"
          end
        end
        
        def unrendered_dom_element(keyword)
          @unrendered_dom_elements ||= {}
          @unrendered_dom_elements[keyword] ||= Element["<#{keyword} />"]
        end
      end
      
      include Glimmer
      
      Event = Struct.new(:widget, keyword_init: true)
      
      HTML_ELEMENT_KEYWORDS = [
        "a", "abbr", "acronym", "address", "applet", "area", "article", "aside", "audio",
        "base", "basefont", "bdi", "bdo", "bgsound", "big", "blink", "blockquote", "body",
        "button", "canvas", "caption", "center", "cite", "code", "col", "colgroup", "data",
        "datalist", "dd", "decorator", "details", "dfn", "dir", "div", "dl", "dt",
        "element", "embed", "fieldset", "figcaption", "figure", "font", "footer", "form", "frame",
        "frameset", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup",
        "hr", "html", "iframe", "img", "input", "isindex", "kbd", "keygen",
        "label", "legend", "li", "link", "listing", "main", "map", "marquee", "menu",
        "menuitem", "meta", "meter", "nav", "nobr", "noframes", "noscript", "object", "ol", "optgroup",
        "option", "output", "p", "param", "plaintext", "pre", "progress", "q", "rp", "rt",
        "ruby", "s", "samp", "script", "section", "select", "shadow", "source", "spacer",
        "span", "strike", "style", "summary", "table", "tbody", "td",
        "template", "textarea", "tfoot", "th", "thead", "time", "title", "tr", "track", "tt",
        "u", "ul", "var", "video", "wbr", "xmp",
      ]
      
      SVG_ELEMENT_KEYWORDS = [
        "animate", "animateMotion", "animateTransform", "circle", "clipPath", "defs", "desc", "ellipse",
        "feBlend", "feColorMatrix", "feComponentTransfer", "feComposite", "feConvolveMatrix",
        "feDiffuseLighting", "feDisplacementMap", "feDistantLight", "feDropShadow", "feFlood", "feFuncA",
        "feFuncB", "feFuncG", "feFuncR", "feGaussianBlur", "feImage", "feMerge", "feMergeNode",
        "feMorphology", "feOffset", "fePointLight", "feSpecularLighting", "feSpotLight", "feTile",
        "feTurbulence", "filter", "foreignObject", "g", "image", "line", "linearGradient", "marker",
        "mask", "metadata", "mpath", "path", "pattern", "polygon", "polyline", "radialGradient", "rect",
        "set", "stop", "svg", "switch", "symbol", "text", "textPath", "tspan", "use", "view",
      ].map(&:downcase)
 
      ELEMENT_KEYWORDS = HTML_ELEMENT_KEYWORDS + SVG_ELEMENT_KEYWORDS

      GLIMMER_ATTRIBUTES = [:parent]
      PROPERTY_ALIASES = {
        'inner_html' => 'innerHTML',
        'outer_html' => 'outerHTML',
      }
      FORMAT_DATETIME = '%Y-%m-%dT%H:%M'
      FORMAT_DATE = '%Y-%m-%d'
      FORMAT_TIME = '%H:%M'
      REGEX_FORMAT_DATETIME = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/
      REGEX_FORMAT_DATE = /^\d{4}-\d{2}-\d{2}$/
      REGEX_FORMAT_TIME = /^\d{2}:\d{2}$/
      REGEX_STYLE_SUB_PROPERTY = /^(style)_(.*)$/
      REGEX_CLASS_NAME_SUB_PROPERTY = /^(class_name)_(.*)$/
      
      attr_reader :keyword, :parent, :parent_component, :ancestor_component, :component, :args, :options, :slot, :children, :enabled, :foreground, :background, :removed, :rendered
      alias rendered? rendered
      alias removed? removed
      
      def initialize(keyword, parent, args, block)
        @keyword = keyword
        @parent = parent.is_a?(Glimmer::Web::Component) ? parent.markup_root : parent
        # @parent_component is the component that is the parent of an external element (not in markup {...} block) that is nested underneath (e.g. address_form { this_element })
        @parent_component = parent if parent.is_a?(Glimmer::Web::Component)
        if Component.interpretation_stack.last&.markup_root.nil?
          # @component is the one tied to this component-internal element as the markup root
          @component = Component.interpretation_stack.last
          @component&.instance_variable_set("@markup_root", self)
        else
          # @ancestor_component is the one tied to this component-internal element as an ancestor
          @ancestor_component = Component.interpretation_stack.last
        end
        @options = args.last.is_a?(Hash) ? args.last.symbolize_keys : {}
        if parent.nil?
          options[:parent] ||= Component.interpretation_stack.last&.options&.[](:parent)
          options[:render] ||= Component.interpretation_stack.last&.options&.[](:render)
          options[:bulk_render] ||= Component.interpretation_stack.last&.options&.[](:bulk_render)
        end
        @slot = options['slot'] || options[:slot]
        @slot = @slot.to_sym if @slot
        puts @slot if @slot
        ancestor_component.slot_elements[@slot] = self if @slot && ancestor_component
        @args = args
        @block = block
        @children = []
        @parent&.post_initialize_child(self)
        render if !bulk_render? && !@rendered && render_after_create?
      end
      
      def ancestor_component
        @ancestor_component || @component
      end
      
      def bulk_render?
        options[:bulk_render] != false && (@parent.nil? || @parent.bulk_render?)
      end
      
      def render_after_create?
        options[:render] != false && (@parent.nil? || @parent.render_after_create?)
      end
      
      # Executes for the parent of a child that just got added
      def post_initialize_child(child)
        @children << child
        child.render if !bulk_render? && !render_after_create?
      end
      
      # Executes for the parent of a child that just got removed
      def post_remove_child(child)
        @children.delete(child)
      end
      
      # Executes at the closing of a parent widget curly braces after all children/properties have been added/set
      def post_add_content
        render if bulk_render? && @parent.nil? && !rendered?
      end
      
      def css_classes
        dom_element.attr('class').to_s.split if rendered?
      end
      
      def html?
        ElementProxy.html_keyword_supported?(keyword)
      end
      
      def svg?
        ElementProxy.svg_keyword_supported?(keyword)
      end
      
      def remove
        return if @removed
        on_remove_listeners = listeners_for('on_remove').dup
        if rendered?
          @children.dup.each do |child|
            child.remove
          end
          remove_all_listeners
          dom_element.remove
        end
        parent&.post_remove_child(self)
        if component
          Glimmer::Web::Component.remove_component(component)
          component.remove_style_block
        end
        @removed = true
        on_remove_listeners.each do |listener|
          listener.original_event_listener.call(EventProxy.new(listener: listener))
        end
      end
      
      def remove_all_listeners
        listeners.each do |event, event_listeners|
          event_listeners.dup.each(&:unregister)
        end
        listeners.clear
        data_bindings.each do |element_binding, model_binding|
          element_binding.unregister_all_observables
        end
        data_bindings.clear
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
      alias ancestors parents

      def find_ancestor(include_self: false, &condition)
        current_element_proxy = self
        return current_element_proxy if include_self && condition.call(current_element_proxy)
        until current_element_proxy.parent.nil?
          current_element_proxy = current_element_proxy.parent
          return current_element_proxy if condition.call(current_element_proxy)
        end
        nil
      end
      
      def print
        `window.print()`
        true
      end

      def enabled=(value)
        if rendered?
          @enabled = value
          dom_element.prop('disabled', !@enabled)
        else
          enqueue_post_render_method_call('enabled=', value)
        end
      end
      
      def foreground=(value)
        if rendered?
          value = ColorProxy.new(value) if value.is_a?(String)
          @foreground = value
          dom_element.css('color', foreground.to_css) unless foreground.nil?
        else
          enqueue_post_render_method_call('foreground=', value)
        end
      end
      
      def background=(value)
        if rendered?
          value = ColorProxy.new(value) if value.is_a?(String)
          @background = value
          dom_element.css('background-color', background.to_css) unless background.nil?
        else
          enqueue_post_render_method_call('background=', value)
        end
      end
      
      def class_name_included(one_class_name, value = nil)
        if rendered?
          if value.nil?
            class_name.include?(one_class_name)
          else
            if value
              add_css_class(one_class_name)
            else
              remove_css_class(one_class_name)
            end
          end
        else
          enqueue_args = ['class_name_included', one_class_name]
          enqueue_args << value unless value.nil?
          enqueue_post_render_method_call(*enqueue_args)
        end
      end
      
      def style(value = null)
        if rendered?
          if value.nil?
            dom_element.attr('style')
          else
            value = normalize_style(value)
            dom_element.attr('style', value)
          end
        else
          enqueue_args = ['style']
          enqueue_args << value unless value.nil?
          enqueue_post_render_method_call(*enqueue_args)
        end
      end
      alias style= style
      
      def style_property(property, value = nil)
        if rendered?
          property = property.to_s.gsub('_', '-')
          if value.nil?
            dom_element.css(property)
          else
            dom_element.css(property, value)
          end
        else
          enqueue_args = ['style_property', property]
          enqueue_args << value unless value.nil?
          enqueue_post_render_method_call(*enqueue_args)
        end
      end
      
      def parent_selector
        @parent&.selector
      end
      
      def parent_dom_element
        if parent
          parent.dom_element
        else
          options[:parent] ||= 'body'
          the_element = Document.find(options[:parent])
          if the_element.length == 0
            options[:parent] = 'body'
            the_element = Document.find('body')
          end
          the_element
        end
      end
      
      def render(parent: nil, custom_parent_dom_element: nil, brand_new: false)
        parent_selector = parent
        options[:parent] = parent_selector if !parent_selector.to_s.empty?
        if !options[:parent].to_s.empty?
          # ensure element is orphaned as it is becoming a top-level root element
          @parent&.post_remove_child(self)
          @parent = nil
        end
        the_parent_dom_element = custom_parent_dom_element || parent_dom_element
        brand_new ||= @dom.nil? || !options[:parent].to_s.empty? || (old_element = dom_element).empty?
        build_dom(layout: !custom_parent_dom_element) # TODO handle custom parent layout by passing parent instead of parent dom element
        if brand_new
          attach(the_parent_dom_element)
        else
          reattach(old_element)
        end
        mark_rendered
        invoke_post_render_method_calls if bulk_render?
        handle_observation_requests
        children.each(&:render) if !bulk_render? && !render_after_create?
        add_contents_for_render_blocks
        notify_on_render_listeners
      end
      alias rerender render
        
      def attach(the_parent_dom_element)
        the_parent_dom_element.append(@dom)
      end
        
      def reattach(old_element)
        old_element.replace_with(@dom)
      end
      
      def mark_rendered
        @rendered = true
        children.each(&:mark_rendered) if bulk_render?
      end
      
      def add_text_content(text, on_empty: false)
        if rendered?
          dom_element.append(text.to_s) if !on_empty || dom_element.text.to_s.empty?
        else
          enqueue_post_render_method_call('add_text_content', text, on_empty:)
        end
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
        @dom = dom # TODO unify how to build dom for most widgets based on element, id, and name (class)
      end
            
      def dom
        # TODO auto-convert known glimmer attributes like parent to data attributes like data-parent
        # TODO check if we need to avoid rendering content block if no content is available
        @dom ||= begin
          content = args.first.is_a?(String) ? args.first : ''
          content += children_dom_content if bulk_render?
          ElementProxy.render_html(keyword, html_options, content)
        end
      end
      
      def children_dom_content
        children.map(&:dom).join
      end
      
      def html_options
        body_class = (base_css_classes + css_classes.to_a).uniq.compact.join(' ')
        html_options = options.dup
        GLIMMER_ATTRIBUTES.each do |attribute|
          next unless html_options.include?(attribute)
          data_normalized_attribute = attribute.split('_').join('-')
          html_options["data-#{data_normalized_attribute}"] = html_options.delete(attribute)
        end
        html_options[:class] ||= ''
        html_options[:class] = "#{normalize_class_name(html_options.delete('class') || html_options.delete(:class))} #{body_class}".strip
        html_options[:style] = normalize_style(html_options.delete('style') || html_options.delete(:style))
        html_options['data-turbo'] = 'false' if parent.nil?
        html_options
      end
      
      def content(bulk_render: false, &block)
        puts 'ElementProxy#content'
        original_bulk_render = options[:bulk_render]
        options[:bulk_render] = bulk_render if rendered?
        return_value = Glimmer::DSL::Engine.add_content(self, Glimmer::DSL::Web::ElementExpression.new, keyword, &block)
        options[:bulk_render] = original_bulk_render if rendered?
        return_value
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
      
      def class_name=(*values)
        if rendered?
          values = normalize_class_name(values).split(' ')
          new_class_name = (base_css_classes + values).uniq.compact.join(' ')
          dom_element.prop('className', new_class_name)
        else
          enqueue_post_render_method_call('class_name=', *values)
        end
      end
      alias classes= class_name=
      
      def add_css_class(css_class)
        if rendered?
          dom_element.add_class(css_class)
        else
          enqueue_post_render_method_call('add_css_class', css_class)
        end
      end
      
      def add_css_classes(css_classes_to_add)
        css_classes_to_add.each {|css_class| add_css_class(css_class)}
      end
      
      def remove_css_class(css_class)
        if rendered?
          dom_element.remove_class(css_class)
        else
          enqueue_post_render_method_call('remove_css_class', css_class)
        end
      end
      
      def remove_css_classes(css_classes_to_remove)
        css_classes_to_remove.each {|css_class| remove_css_class(css_class)}
      end
      
      def clear_css_classes
        css_classes.each {|css_class| remove_css_class(css_class)}
      end
      
      def dom_element
        if rendered?
          # TODO consider making this pick an element in relation to its parent, allowing unhooked dom elements to be built if needed (unhooked to the visible page dom)
          Document.find(selector)
        else
          # Using a fill-in dom element until self is rendered
          ElementProxy.unrendered_dom_element(keyword)
        end
      end
      
      # TODO consider adding a default #dom method implementation for the common case, automatically relying on #element and other methods to build the dom html
      
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
        if rendered?
          listener = ListenerProxy.new(
            element: self,
            selector: selector,
            dom_element: dom_element,
            event_attribute: keyword,
            original_event_listener: original_event_listener,
          )
          listener.register
          listeners_for(keyword) << listener
          listener
        else
          enqueue_post_render_method_call('handle_observation_request', keyword, original_event_listener)
        end
      end
      
      def remove_event_listener_proxies
        event_listener_proxies.each do |event_listener_proxy|
          event_listener_proxy.unregister
        end
        event_listener_proxies.clear
      end
      
      def notify_listeners(event)
        listeners_for(event).each do |listener|
          listener.original_event_listener.call(EventProxy.new(listener: listener))
        end
      end
      
      def notify_on_render_listeners
        notify_listeners('on_render')
        children.each(&:notify_on_render_listeners) if bulk_render?
      end
      
      def data_bindings
        @data_bindings ||= {}
      end
      
      def type
        if rendered?
          super
        else
          options[:type] || 'text'
        end
      end
      
      def data_bind(property, model_binding)
        element_binding_read_translator = value_converters_for_input_type(type)&.[](:model_to_view)
        element_binding = DataBinding::ElementBinding.new(self, property, translator: element_binding_read_translator)
        #TODO make this options observer dependent and all similar observers in element specific data binding handlers
        element_binding.observe(model_binding)
        element_binding.call(model_binding.evaluate_property)
        data_bindings[element_binding] = model_binding
        if !model_binding.binding_options[:read_only]
          # TODO add guards against nil cases for hash below
          listener_keyword = data_binding_listener_for_element_and_property(keyword, property)
          if listener_keyword
            data_binding_read_listener = lambda do |event|
              view_property_value = send(property)
              element_binding_write_translator = value_converters_for_input_type(type)&.[](:view_to_model)
              converted_view_property_value = element_binding_write_translator&.call(view_property_value, model_binding.evaluate_property) || view_property_value
              model_binding.call(converted_view_property_value)
            end
            handle_observation_request(listener_keyword, data_binding_read_listener)
          end
        end
      end
      
      # Data-binds the generation of nested content to a model/property (in binding args)
      # consider providing an option to avoid initial rendering without any changes happening
      def bind_content(*binding_args, &content_block)
        content_binding_work = proc do |*values|
          # TODO in the future, consider optimizing code by diffing content if that makes sense (e.g. using opal-virtual-dom)
          # To do so, we must avoid generating new content with new unique IDs/Classes and only append the new IDs classes after mounting
          # TODO consider optimizing remove performance by doing clear instead and removing listeners separately
          children.dup.each { |child| child.remove }
          content(bulk_render: true, &content_block)
          if bulk_render? && rendered?
            self.inner_html = children_dom_content
            children.each(&:mark_rendered)
            children.each(&:invoke_post_render_method_calls)
            children.each(&:handle_observation_requests)
            children.each(&:add_contents_for_render_blocks)
            children.each(&:notify_on_render_listeners)
          end
        end
        model_binding_observer = Glimmer::DataBinding::ModelBinding.new(*binding_args)
        content_binding_observer = Glimmer::DataBinding::Observer.proc(&content_binding_work)
        content_binding_observer.observe(model_binding_observer)
        content_binding_work.call # TODO inspect if we need to pass args here (from observed attributes) [but it's simpler not to pass anything at first]
      end
      
      def respond_to_missing?(method_name, include_private = false)
        # TODO consider doing more correct checking of availability of properties/methods using native ticks
        property_name = property_name_for(method_name)
        unnormalized_property_name = unnormalized_property_name_for(method_name)
        super(method_name, include_private) ||
          (dom_element && dom_element.length > 0 && Native.call(dom_element, '0').respond_to?(method_name.to_s.camelcase, include_private)) ||
          (dom_element && dom_element.length > 0 && Native.call(dom_element, '0').respond_to?(method_name.to_s, include_private)) ||
          dom_element.respond_to?(method_name, include_private) ||
          (!dom_element.prop(property_name).nil? && !dom_element.prop(property_name).is_a?(Proc)) ||
          (!dom_element.prop(unnormalized_property_name).nil? && !dom_element.prop(unnormalized_property_name).is_a?(Proc)) ||
          method_name.to_s.start_with?('on_') ||
          method_name.to_s.start_with?('style_') ||
          method_name.to_s.start_with?('class_name_')
      end
      
      def method_missing(method_name, *args, &block)
        # TODO consider doing more correct checking of availability of properties/methods using native ticks
        property_name = property_name_for(method_name)
        unnormalized_property_name = unnormalized_property_name_for(method_name)
        if method_name.to_s.start_with?('class_name_')
          property, sub_property = method_name.to_s.match(REGEX_CLASS_NAME_SUB_PROPERTY).to_a.drop(1)
          if args.empty?
            class_name_included(sub_property)
          else
            class_name_included(sub_property, args.first)
          end
        elsif method_name.to_s.start_with?('style_')
          property, sub_property = method_name.to_s.match(REGEX_STYLE_SUB_PROPERTY).to_a.drop(1)
          sub_property = sub_property.gsub('_', '-')
          if args.empty?
            style_property(sub_property)
          else
            style_property(sub_property, args.first) # TODO in the future, support more sophisticated forms of CSS sub-property values, like [1.px, :solid, :black] for border
          end
        elsif method_name.to_s.start_with?('on_')
          handle_observation_request(method_name, block)
        elsif dom_element.respond_to?(method_name)
          if rendered?
            dom_element.send(method_name, *args, &block)
          else
            enqueue_post_render_method_call(method_name, *args, &block)
          end
        elsif !dom_element.prop(property_name).nil? && !dom_element.prop(property_name).is_a?(Proc)
          if rendered?
            if method_name.end_with?('=')
              dom_element.prop(property_name, *args)
            else
              dom_element.prop(property_name)
            end
          else
            enqueue_post_render_method_call(method_name, *args, &block)
          end
        elsif !dom_element.prop(unnormalized_property_name).nil? && !dom_element.prop(unnormalized_property_name).is_a?(Proc)
          if rendered?
            if method_name.end_with?('=')
              dom_element.prop(unnormalized_property_name, *args)
            else
              dom_element.prop(unnormalized_property_name)
            end
          else
            enqueue_post_render_method_call(method_name, *args, &block)
          end
        elsif dom_element && dom_element.length > 0
          if rendered?
            js_args = block.nil? ? args : (args + [block])
            begin
              Native.call(dom_element, '0').method_missing(method_name.to_s.camelcase, *js_args)
            rescue Exception => e
              begin
                Native.call(dom_element, '0').method_missing(method_name.to_s, *js_args)
              rescue Exception => e
                super(method_name, *args, &block)
              end
            end
          else
            enqueue_post_render_method_call(method_name, *args, &block)
          end
        else
          super(method_name, *args, &block)
        end
      end
      
      def post_render_method_calls
        @post_render_method_calls ||= []
      end
      
      def enqueue_post_render_method_call(method_name, *args, &block)
        post_render_method_calls << [method_name, args, block]
        nil
      end
      
      def invoke_post_render_method_calls
        return unless rendered?
        post_render_method_calls.each do |method_name, args, block|
          send(method_name, *args, &block)
        end
        children.each(&:invoke_post_render_method_calls) if bulk_render?
      end
      
      def handle_observation_requests
        observation_requests&.each do |keyword, event_listener_set|
          event_listener_set.each do |event_listener|
            handle_observation_request(keyword, event_listener)
          end
        end
        children.each(&:handle_observation_requests) if bulk_render?
      end
      
      def add_contents_for_render_blocks
        unless skip_content_on_render_blocks?
          content_on_render_blocks.each do |content_block|
            content(&content_block)
          end
        end
        children.each(&:add_contents_for_render_blocks) if bulk_render?
      end
      
      def property_name_for(method_name)
        attribute_name = method_name.end_with?('=') ? method_name.to_s[0...-1] : method_name.to_s
        PROPERTY_ALIASES[attribute_name] || attribute_name.camelcase
      end
      
      def unnormalized_property_name_for(method_name)
        method_name.end_with?('=') ? method_name.to_s[0...-1] : method_name.to_s
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
        input_value_converters[input_type]
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
      
      def base_css_classes
        framework_css_classes = [name, element_id]
        if component
          framework_css_classes.prepend(component.class.component_element_class)
          framework_css_classes.prepend(component.class.component_shortcut_element_class) if component.class.component_shortcut_element_class != component.class.component_element_class
        end
        framework_css_classes
      end
      
      def valid_js_date_string?(string)
        [REGEX_FORMAT_DATETIME, REGEX_FORMAT_DATE, REGEX_FORMAT_TIME].any? do |format|
          string.match(format)
        end
      end
      
      def css_cursor
        SWT_CURSOR_TO_CSS_CURSOR_MAP[@cursor]
      end
      
      def normalize_class_name(class_name_value)
        if class_name_value.is_a?(Array)
          class_name_value.map(&:to_s).join(' ')
        else
          class_name_value.to_s
        end
      end
      
      def normalize_style(style_value)
        if style_value.is_a?(Hash)
          style_value.reduce('') do |output, (key, value)|
            key = key.to_s.gsub('_', '-')
            value = value.px if value.is_a?(Numeric)
            output += "#{key}: #{value}; "
          end
        else
          style_value.to_s
        end
      end
      
    end
  end
end

require 'glimmer/dsl/web/element_expression'
