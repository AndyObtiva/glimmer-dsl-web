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

require 'glimmer'
require 'glimmer/error'
require 'glimmer/swt/display_proxy'
require 'glimmer/util/proc_tracker'
require 'glimmer/data_binding/observer'
require 'glimmer/data_binding/observable_model'

module Glimmer
  module UI
    module CustomWidget
      include DataBinding::ObservableModel
      
      module ClassMethods
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
            # TODO fix this in Opal by switching to define_method
            define_method(option) do
              options[:"#{option}"]
            end
            define_method("#{option}=") do |option_value|
              self.options[:"#{option}"] = option_value
            end
          end
        end

        def before_body(&block)
          @before_body_blocks ||= []
          @before_body_blocks << block
        end

        def body(&block)
          @body_block = block
        end

        def after_body(&block)
          @after_body_blocks ||= []
          @after_body_blocks << block
        end
        
        def keyword
          self.name.underscore.gsub('::', '__')
        end
        
        # Returns shortcut keyword to use for this custom widget (keyword minus namespace)
        def shortcut_keyword
          self.name.underscore.gsub('::', '__').split('__').last
        end
        
      end
      
      class << self
        def included(klass)
          klass.extend(ClassMethods)
          unless klass.name.include?('Glimmer::UI::CustomShell')
            klass.include(Glimmer)
            Glimmer::UI::CustomWidget.add_custom_widget_namespaces_for(klass)
          end
        end
      
        def for(underscored_custom_widget_name)
          extracted_namespaces = underscored_custom_widget_name.
            to_s.
            split(/__/).map do |namespace|
              namespace.camelcase(:upper)
            end
          custom_widget_namespaces.each do |base|
            extracted_namespaces.reduce(base) do |result, namespace|
              if !result.constants.include?(namespace)
                namespace = result.constants.detect {|c| c.to_s.upcase == namespace.to_s.upcase } || namespace
              end
              begin
                constant = result.const_get(namespace)
                return constant if constant&.respond_to?(:ancestors) && constant&.ancestors&.to_a.include?(Glimmer::UI::CustomWidget)
                constant
              rescue => e
                # Glimmer::Config.logger.debug {"#{e.message}\n#{e.backtrace.join("\n")}"}
                result
              end
            end
          end
          raise "#{underscored_custom_widget_name} has no custom widget class!"
        rescue => e
          Glimmer::Config.logger.debug {e.message}
          Glimmer::Config.logger.debug {"#{e.message}\n#{e.backtrace.join("\n")}"}
          nil
        end
 
        def add_custom_widget_namespaces_for(klass)
          Glimmer::UI::CustomWidget.namespaces_for_class(klass).drop(1).each do |namespace|
            Glimmer::UI::CustomWidget.custom_widget_namespaces << namespace
          end
        end

        def namespaces_for_class(m)
          return [m] if m.name.nil?
          namespace_constants = m.name.split(/::/).map(&:to_sym)
          namespace_constants.reduce([Object]) do |output, namespace_constant|
            output += [output.last.const_get(namespace_constant)]
          end[1..-1].uniq.reverse
        end

        def custom_widget_namespaces
          @custom_widget_namespaces ||= reset_custom_widget_namespaces
        end

        def reset_custom_widget_namespaces
          @custom_widget_namespaces = Set[Object, Glimmer::UI]
        end
      end
      # <- end of class methods
      

      attr_reader :body_root, :parent, :options, :swt_style
      alias parent_proxy parent

      def initialize(parent, args, options, &content)
        @parent = parent
        options = args.delete_at(-1) if args.is_a?(Array) && args.last.is_a?(Hash)
        if args.is_a?(Hash)
          options = args
          args = []
        end
        options ||= {}
        args = options.delete('swt_style').split(',').map(&:to_sym) if options['swt_style']
        @args = args
        @swt_style = SWT::SWTProxy[*@args]
        options ||= {}
        @options = self.class.options.merge(options)
        @content = Util::ProcTracker.new(content) if content
        execute_hooks('before_body')
        body_block = self.class.instance_variable_get("@body_block")
        raise Glimmer::Error, 'Invalid custom widget for having no body! Please define body block!' if body_block.nil?
        @body_root = instance_exec(&body_block)
        @parent ||= @body_root.parent
        raise Glimmer::Error, 'Invalid custom widget for having an empty body! Please fill body block!' if @body_root.nil?
        execute_hooks('after_body')
      end
      
      # Subclasses may override to perform post initialization work on an added child
      def post_initialize_child(child)
        # No Op by default
      end

      def can_handle_observation_request?(observation_request)
        observation_request = observation_request.to_s
        result = false
        if observation_request.start_with?('on_updated_')
          property = observation_request.sub(/^on_updated_/, '')
          result = can_add_observer?(property)
        end
        result || body_root&.can_handle_observation_request?(observation_request)
      end

      def handle_observation_request(observation_request, block)
        observation_request = observation_request.to_s
        if observation_request.start_with?('on_updated_')
          property = observation_request.sub(/^on_updated_/, '') # TODO look into eliminating duplication from above
          add_observer(DataBinding::Observer.proc(&block), property) if can_add_observer?(property)
        else
          body_root.handle_observation_request(observation_request, block)
        end
      end

      def can_add_observer?(attribute_name)
        has_instance_method?(attribute_name) || has_instance_method?("#{attribute_name}?") || @body_root.can_add_observer?(attribute_name)
      end

      def add_observer(observer, attribute_name)
        if has_instance_method?(attribute_name)
          super
        else
          @body_root.add_observer(observer, attribute_name)
        end
      end

      def has_attribute?(attribute_name, *args)
        has_instance_method?(attribute_setter(attribute_name)) ||
          @body_root.has_attribute?(attribute_name, *args)
      end

      def set_attribute(attribute_name, *args)
        if has_instance_method?(attribute_setter(attribute_name))
          send(attribute_setter(attribute_name), *args)
        else
          @body_root.set_attribute(attribute_name, *args)
        end
      end

      # This method ensures it has an instance method not coming from Glimmer DSL
      def has_instance_method?(method_name)
        respond_to?(method_name) and
          !body_root&.respond_to?(method_name) and
          !method(method_name)&.source_location&.first&.include?('glimmer/dsl/engine.rb') and
          !method(method_name)&.source_location&.first&.include?('glimmer/swt/widget_proxy.rb')
      end

      def get_attribute(attribute_name)
        if has_instance_method?(attribute_name)
          send(attribute_name)
        else
          @body_root.get_attribute(attribute_name)
        end
      end

      def attribute_setter(attribute_name)
        "#{attribute_name}="
      end

      def has_style?(symbol)
        @args.include?(symbol) # not a very solid implementation. Bring SWT constants eventually
      end

      def async_exec(&block)
        SWT::DisplayProxy.instance.async_exec(&block)
      end

      # sync_exec kept for API compatibility reasons
      def sync_exec(&block)
        SWT::DisplayProxy.instance.async_exec(&block)
      end

      # Returns content block if used as an attribute reader (no args)
      # Otherwise, if a block is passed, it adds it as content to this custom widget
      def content(&block)
        if block_given?
          Glimmer::DSL::Engine.add_content(self, Glimmer::DSL::Opal::CustomWidgetExpression.new, self.class.keyword, &block)
        else
          @content
        end
      end

      def method_missing(method, *args, &block)
        if can_handle_observation_request?(method)
          handle_observation_request(method, block)
        else
          body_root.send(method, *args, &block)
        end
      end

      alias local_respond_to? respond_to?
      def respond_to?(method_name, include_private = false)
        super(method_name, include_private) or
          can_handle_observation_request?(method_name) or
          body_root.respond_to?(method_name, include_private)
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
