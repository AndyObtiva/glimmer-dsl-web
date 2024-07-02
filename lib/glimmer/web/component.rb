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

require 'glimmer'
require 'glimmer/error'
require 'glimmer/util/proc_tracker'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/observable_model'

module Glimmer
  module Web
    module Component
      include DataBinding::ObservableModel
      
      module ClassMethods
        include Glimmer
        
        # Allows defining convenience option accessors for an array of option names
        # Example: `options :color1, :color2` defines `#color1` and `#color2`
        # where they return the instance values `options[:color1]` and `options[:color2]`
        # respectively.
        # Can be called multiple times to set more options additively.
        # When passed no arguments, it returns list of all option names captured so far
        def options(*new_options)
          new_options = new_options.compact.map(&:to_s).map(&:to_sym)
          if new_options.empty?
            @options ||= {} # maps options to defaults
          else
            new_options = new_options.reduce({}) {|new_options_hash, new_option| new_options_hash.merge(new_option => nil)}
            @options = options.merge(new_options)
            def_option_attr_accessors(new_options)
          end
        end
        alias attributes options

        def option(new_option, default: nil)
          new_option = new_option.to_s.to_sym
          new_options = {new_option => default}
          '@options = options.merge(new_options)'
          @options = options.merge(new_options)
          'def_option_attr_accessors(new_options)'
          def_option_attr_accessors(new_options)
        end
        alias attribute option

        def def_option_attr_accessors(new_options)
          new_options.each do |option, default|
            define_method(option) do
              options[:"#{option}"]
            end
            define_method("#{option}=") do |option_value|
              self.options[:"#{option}"] = option_value
            end
          end
        end

        def before_render(&block)
          @before_render_blocks ||= []
          @before_render_blocks << block
        end

        def markup(&block)
          @markup_block = block
        end

        def after_render(&block)
          @after_render_blocks ||= []
          @after_render_blocks << block
        end
        
        def keyword
          self.name.underscore.gsub('::', '__')
        end
        
        # Returns shortcut keyword to use for this component (keyword minus namespace)
        def shortcut_keyword
          self.name.underscore.gsub('::', '__').split('__').last
        end
        
        # Creates component without rendering
        def create(*args)
          args << {} unless args.last.is_a?(Hash)
          args.last[:render] = false
          rendered_component = send(keyword, *args)
          rendered_component
        end
        
        # Creates and renders component
        def render(*args)
          rendered_component = send(keyword, *args)
          rendered_component
        end
      end
      
      # This module was only created to prevent Glimmer from checking method_missing first
      module GlimmerSupersedable
        def method_missing(method_name, *args, &block)
          Glimmer::DSL::Engine.interpret(method_name, *args, &block)
        rescue
          super(method_name, *args, &block)
        end
      end
      
      ADD_COMPONENT_KEYWORDS_UPON_INHERITANCE = proc do
        class << self
          def inherited(subclass)
            Glimmer::Web::Component.add_component_keyword_to_classes_map_for(subclass)
            subclass.class_eval(&Glimmer::Web::Component::ADD_COMPONENT_KEYWORDS_UPON_INHERITANCE)
          end
        end
      end
      
      class << self
        def included(klass)
          if !klass.ancestors.include?(GlimmerSupersedable)
            klass.extend(ClassMethods)
            klass.include(Glimmer)
            klass.prepend(GlimmerSupersedable)
            Glimmer::Web::Component.add_component_keyword_to_classes_map_for(klass)
            klass.class_eval(&Glimmer::Web::Component::ADD_COMPONENT_KEYWORDS_UPON_INHERITANCE)
          end
        end
      
        def for(underscored_component_name)
          component_classes = Glimmer::Web::Component.component_keyword_to_classes_map[underscored_component_name]
          if component_classes.nil? || component_classes.empty?
            Glimmer::Config.logger.debug {"#{underscored_component_name} has no Glimmer web component class!" }
            nil
          else
            component_class = component_classes.first
          end
        end
 
        def add_component_keyword_to_classes_map_for(component_class)
          keywords_for_class(component_class).each do |keyword|
            Glimmer::Web::Component.component_keyword_to_classes_map[keyword] ||= []
            Glimmer::Web::Component.component_keyword_to_classes_map[keyword] << component_class
          end
        end

        def keywords_for_class(component_class)
          namespaces = component_class.to_s.split(/::/).map(&:underscore).reverse
          namespaces.size.times.map { |n| namespaces[0..n].reverse.join('__') }
        end

        def component_keyword_to_classes_map
          @component_keyword_to_classes_map ||= reset_component_keyword_to_classes_map
        end

        def reset_component_keyword_to_classes_map
          @component_keyword_to_classes_map = {}
        end
        
        def interpretation_stack
          @interpretation_stack ||= []
        end
      end
      # <- end of class methods
      

      attr_reader :markup_root, :parent, :args, :options
      alias parent_proxy parent

      def initialize(parent, args, options, &content)
        Component.interpretation_stack.push(self)
        @parent = parent
        options = args.delete_at(-1) if args.is_a?(Array) && args.last.is_a?(Hash)
        if args.is_a?(Hash)
          options = args
          args = []
        end
        options ||= {}
        @args = args
        options ||= {}
        @options = self.class.options.merge(options)
        @content = Util::ProcTracker.new(content) if content
        execute_hooks('before_render')
        markup_block = self.class.instance_variable_get("@markup_block")
        raise Glimmer::Error, 'Invalid Glimmer web component for having no markup! Please define markup block!' if markup_block.nil?
        @markup_root = instance_exec(&markup_block)
        @markup_root.options[:parent] = options[:parent] if !options[:parent].nil?
        @parent ||= @markup_root.parent
        raise Glimmer::Error, 'Invalid Glimmer web component for having an empty markup! Please fill markup block!' if @markup_root.nil?
        if options[:render] != false
          execute_hooks('after_render')
        else
          on_render_listener = proc { execute_hooks('after_render') }
          @markup_root.handle_observation_request('on_render', on_render_listener)
        end
        
        # TODO adapt for web
        observer_registration_cleanup_listener = proc do
          observer_registrations.compact.each(&:deregister)
          observer_registrations.clear
        end
        @markup_root.handle_observation_request('on_remove', observer_registration_cleanup_listener)
        post_add_content if content.nil?
      end
      
      # Subclasses may override to perform post initialization work on an added child
      def post_initialize_child(child)
        # No Op by default
      end

      def post_add_content
        Component.interpretation_stack.pop
      end
      
      # This stores observe keyword registrations of model/attribute observers
      def observer_registrations
        @observer_registrations ||= []
      end

      def can_handle_observation_request?(observation_request)
        observation_request = observation_request.to_s
        result = false
        if observation_request.start_with?('on_updated_')
          property = observation_request.sub(/^on_updated_/, '')
          result = can_add_observer?(property)
        end
        result || markup_root&.can_handle_observation_request?(observation_request)
      end

      def handle_observation_request(observation_request, block)
        observation_request = observation_request.to_s
        if observation_request.start_with?('on_updated_')
          property = observation_request.sub(/^on_updated_/, '') # TODO look into eliminating duplication from above
          add_observer(DataBinding::Observer.proc(&block), property) if can_add_observer?(property)
        else
          markup_root.handle_observation_request(observation_request, block)
        end
      end

      def can_add_observer?(attribute_name)
        has_instance_method?(attribute_name) || has_instance_method?("#{attribute_name}?") || @markup_root.can_add_observer?(attribute_name)
      end

      def add_observer(observer, attribute_name)
        if has_instance_method?(attribute_name)
          super(observer, attribute_name)
        else
          @markup_root.add_observer(observer, attribute_name)
        end
      end

      def has_attribute?(attribute_name, *args)
        has_instance_method?(attribute_setter(attribute_name)) ||
          @markup_root.has_attribute?(attribute_name, *args)
      end

      def set_attribute(attribute_name, *args)
        if has_instance_method?(attribute_setter(attribute_name))
          send(attribute_setter(attribute_name), *args)
        else
          @markup_root.set_attribute(attribute_name, *args)
        end
      end

      # This method ensures it has an instance method not coming from Glimmer DSL
      def has_instance_method?(method_name)
        respond_to?(method_name) and
          !markup_root&.respond_to?(method_name) and
          !method(method_name)&.source_location&.first&.include?('glimmer/dsl/engine.rb') and
          !method(method_name)&.source_location&.first&.include?('glimmer/web/element_proxy.rb')
      end

      def get_attribute(attribute_name)
        if has_instance_method?(attribute_name)
          send(attribute_name)
        else
          @markup_root.get_attribute(attribute_name)
        end
      end

      def attribute_setter(attribute_name)
        "#{attribute_name}="
      end
      
      def render(parent: nil, custom_parent_dom_element: nil, brand_new: false)
        # this method is defined to prevent displaying a harmless Glimmer no keyword error as an annoying useless warning
        @markup_root&.render(parent: parent, custom_parent_dom_element: custom_parent_dom_element, brand_new: brand_new)
      end
      
      def remove
        @markup_root&.remove
      end

      def data_bind(property, model_binding)
        @markup_root&.data_bind(property, model_binding)
      end
      
      def bind_content(*binding_args, &content_block)
        @markup_root&.bind_content(*binding_args, &content_block)
      end
      
      # Returns content block if used as an attribute reader (no args)
      # Otherwise, if a block is passed, it adds it as content to this Glimmer web component
      def content(*args, &block)
        if args.empty?
          if block_given?
            Glimmer::DSL::Engine.add_content(self, Glimmer::DSL::Web::ComponentExpression.new, self.class.keyword, &block)
          else
            @content
          end
        else
          # delegate to GUI DSL ContentExpression
          super
        end
      end

      def method_missing(method_name, *args, &block)
        if can_handle_observation_request?(method_name)
          handle_observation_request(method_name, block)
        elsif markup_root.respond_to?(method_name, true)
          markup_root.send(method_name, *args, &block)
        else
          super(method_name, *args, &block)
        end
      end

      alias local_respond_to? respond_to_missing?
      def respond_to_missing?(method_name, include_private = false)
        super(method_name, include_private) or
          can_handle_observation_request?(method_name) or
          markup_root.respond_to?(method_name, include_private)
      end

      private

      def execute_hooks(hook_name)
        self.class.instance_variable_get("@#{hook_name}_blocks")&.each do |hook_block|
          instance_exec(&hook_block)
        end
      end
    end
  end
end
