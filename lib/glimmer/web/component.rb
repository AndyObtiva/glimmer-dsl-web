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

        def option(new_option, default: nil)
          new_option = new_option.to_s.to_sym
          new_options = {new_option => default}
          '@options = options.merge(new_options)'
          @options = options.merge(new_options)
          'def_option_attr_accessors(new_options)'
          def_option_attr_accessors(new_options)
        end

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
      
      class << self
        def included(klass)
          if !klass.ancestors.include?(GlimmerSupersedable)
            klass.extend(ClassMethods)
            klass.include(Glimmer)
            klass.prepend(GlimmerSupersedable)
            Glimmer::Web::Component.add_component_namespaces_for(klass)
          end
        end
      
        def for(underscored_component_name)
          extracted_namespaces = underscored_component_name.
            to_s.
            split(/__/).map do |namespace|
              namespace.camelcase(:upper)
            end
          Glimmer::Web::Component.component_namespaces.each do |base|
            extracted_namespaces.reduce(base) do |result, namespace|
              if !result.constants.include?(namespace)
                namespace = result.constants.detect {|c| c.to_s.upcase == namespace.to_s.upcase } || namespace
              end
              begin
                constant = result.const_get(namespace)
                return constant if constant&.respond_to?(:ancestors) &&
                                   (
                                     constant&.ancestors&.to_a.include?(Glimmer::Web::Component) ||
                                     # TODO checking GlimmerSupersedable as a hack because when a class is loaded twice (like when loading samples
                                     # by reloading ruby files), it loses its Glimmer::Web::Component ancestor as a bug in Opal
                                     # but somehow the prepend module remains
                                     constant&.ancestors&.to_a.include?(GlimmerSupersedable)
                                   )
                constant
              rescue => e
                # Glimmer::Config.logger.debug {"#{e.message}\n#{e.backtrace.join("\n")}"}
                result
              end
            end
          end
          raise "#{underscored_component_name} has no Glimmer web component class!"
        rescue => e
          Glimmer::Config.logger.debug {e.message}
          Glimmer::Config.logger.debug {"#{e.message}\n#{e.backtrace.join("\n")}"}
          nil
        end
 
        def add_component_namespaces_for(klass)
          Glimmer::Web::Component.namespaces_for_class(klass).drop(1).each do |namespace|
            Glimmer::Web::Component.component_namespaces << namespace
          end
        end

        def namespaces_for_class(m)
          return [m] if m.name.nil?
          namespace_constants = m.name.split(/::/).map(&:to_sym)
          namespace_constants.reduce([Object]) do |output, namespace_constant|
            output += [output.last.const_get(namespace_constant)]
          end[1..-1].uniq.reverse
        end

        def component_namespaces
          @component_namespaces ||= reset_component_namespaces
        end

        def reset_component_namespaces
          @component_namespaces = Set[Object, Glimmer::Web]
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
