# Copyright (c) 2007-2022 Andy Maleh
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

require 'glimmer/swt/property_owner'
require 'glimmer/swt/swt_proxy'
require 'glimmer/swt/display_proxy'
require 'glimmer/swt/color_proxy'
require 'glimmer/swt/font_proxy'
# require 'glimmer/swt/transform_proxy'
require 'glimmer/swt/point'
require 'glimmer/swt/rectangle'

module Glimmer
  module SWT
    module Custom
      # Represents a shape (graphics) to be drawn on a control/widget/canvas/display
      # That is because Shape is drawn on a parent as graphics and doesn't have an SWT widget for itself
      class Shape < WidgetProxy
        include PropertyOwner
        
        class << self
          def create(parent, keyword, args, &property_block)
            potential_shape_class_name = keyword.to_s.camelcase(:upper).to_sym
            if constants.include?(potential_shape_class_name)
              const_get(potential_shape_class_name).new(parent, args, property_block)
            else
              new(parent, args, property_block)
            end
          end
        
          def valid?(parent, keyword, args, &block)
            return true if keyword.to_s == 'shape'
            keywords.include?(keyword.to_s)
          end
          
          def keywords
            constants.select do |constant|
              constant_value = const_get(constant)
              constant_value.respond_to?(:ancestors) && constant_value.ancestors.include?(Glimmer::SWT::Custom::Shape)
            end.map {|constant| constant.to_s.underscore}
          end
          
        end
        
        def background=(value)
          value = ColorProxy.new(value) if value.is_a?(String) || value.is_a?(Symbol)
          @background = value
          dom_element.css('fill', background.to_css) unless background.nil?
        end
        
        def foreground=(value)
          value = ColorProxy.new(value) if value.is_a?(String) || value.is_a?(Symbol)
          @foreground = value
          dom_element.css('stroke', foreground.to_css) unless foreground.nil?
          dom_element.css('fill', 'transparent') if background.nil?
        end
        
        def post_add_content
          # TODO avoid rendering unless args changed from initialize args (due to setting of piecemeal attributes)
          render
        end
        
        def render(custom_parent_dom_element: nil, brand_new: false)
          super(custom_parent_dom_element: nil, brand_new: false)
          self.background = background
          self.foreground = foreground
          self.font = font
        end
        
        # parameter names for arguments to pass to SWT GC.xyz method for rendering shape (e.g. draw_image(image, x, y) yields :image, :x, :y parameter names)
        def parameter_names
          [:x, :y, :width, :height]
        end
        
        # subclasses may override to specify location parameter names if different from x and y (e.g. all polygon points are location parameters)
        # used in calculating movement changes
        def location_parameter_names
          [:x, :y]
        end
        
        def possible_parameter_names
          parameter_names
        end
        
        def parameter_name?(attribute_name)
          possible_parameter_names.map(&:to_s).include?(attribute_getter(attribute_name))
        end
        
        def current_parameter_name?(attribute_name)
          parameter_names.include?(attribute_name.to_s.to_sym)
        end
        
        def parameter_index(attribute_name)
          parameter_names.index(attribute_name.to_s.to_sym)
        end
        
        def get_parameter_attribute(attribute_name)
          @args[parameter_index(attribute_getter(attribute_name))]
        end
        
        def set_parameter_attribute(attribute_name, *args)
          @args[parameter_index(attribute_getter(attribute_name))] = args.size == 1 ? args.first : args
        end
        
        def has_attribute?(attribute_name, *args)
          parameter_name?(attribute_name) or
            (respond_to?(attribute_name, super: true) and respond_to?(attribute_setter(attribute_name), super: true))
        end
        
        def set_attribute(attribute_name, *args)
          attribute_getter_name = attribute_getter(attribute_name)
          attribute_setter_name = attribute_setter(attribute_name)
          if parameter_name?(attribute_name)
            return if attribute_getter_name == (args.size == 1 ? args.first : args)
            set_parameter_attribute(attribute_getter_name, *args)
          elsif (respond_to?(attribute_name, super: true) and respond_to?(attribute_setter_name, super: true))
            return if self.send(attribute_getter_name) == (args.size == 1 ? args.first : args)
            self.send(attribute_setter_name, *args)
          end
        end
        
        def get_attribute(attribute_name)
          if parameter_name?(attribute_name)
            arg_index = parameter_index(attribute_name)
            @args[arg_index] if arg_index
          elsif (respond_to?(attribute_name, super: true) and respond_to?(attribute_setter(attribute_name), super: true))
            self.send(attribute_name)
          end
        end
        
        # TODO look why image is not working with the method_missing and respond_to? on shape
        def method_missing(method_name, *args, &block)
          if method_name.to_s.end_with?('=')
            set_attribute(method_name, *args)
          elsif has_attribute?(method_name) && args.empty?
            get_attribute(method_name)
          else # TODO support proxying calls to handle_observation_request for listeners just like WidgetProxy
            super(method_name, *args, &block)
          end
        end

        def respond_to?(method_name, *args, &block)
          options = args.last if args.last.is_a?(Hash)
          super_invocation = options && options[:super]
          if !super_invocation && has_attribute?(method_name)
            true
          else
            super(method_name, (args.first if args.first == true), &block)
          end
        end
        
        def attach(the_parent_dom_element)
          the_parent_dom_element.html("#{the_parent_dom_element.html()}\n#{@dom}")
        end
        
        def element
          'g'
        end
        
        def dom
          shape_id = id
          shape_class = name
          @dom ||= xml {
            g(id: shape_id, class: shape_class) {
            }
          }.to_s
        end
        
        # TODO implement shape_at_location potentially with document.elementFromPoint(x, y);
        
      end
      
    end
    
  end
  
end

require 'glimmer/swt/custom/shape/arc'
require 'glimmer/swt/custom/shape/image'
require 'glimmer/swt/custom/shape/line'
require 'glimmer/swt/custom/shape/oval'
require 'glimmer/swt/custom/shape/point'
require 'glimmer/swt/custom/shape/polygon'
require 'glimmer/swt/custom/shape/polyline'
require 'glimmer/swt/custom/shape/rectangle'
require 'glimmer/swt/custom/shape/text'
