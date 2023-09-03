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

require 'glimmer/swt/custom/shape'
require 'glimmer/swt/swt_proxy'
require 'glimmer/swt/display_proxy'
require 'glimmer/swt/color_proxy'
# require 'glimmer/swt/transform_proxy'

module Glimmer
  module SWT
    module Custom
      class Shape
        class Rectangle < Shape
        
          def parameter_names
            if @parameter_names.nil?
              if rectangle_parameter_names.size == @args.size
                @parameter_names = rectangle_parameter_names
              elsif rectangle_round_parameter_names.size == @args.size
                @parameter_names = rectangle_round_parameter_names
              elsif rectangle_gradient_parameter_names.size == @args.size
                @parameter_names = rectangle_gradient_parameter_names
              elsif rectangle_rectangle_parameter_names.size == @args.size
                @parameter_names = rectangle_rectangle_parameter_names
              end
            end
            @parameter_names || rectangle_parameter_names
          end
          
          def possible_parameter_names
            # TODO refactor and improve this method through meta-programming (and share across other shapes)
            (rectangle_round_parameter_names + rectangle_parameter_names + rectangle_gradient_parameter_names + rectangle_rectangle_parameter_names).uniq
          end
          
          def rectangle_round_parameter_names
            [:x, :y, :width, :height, :arc_width, :arc_height]
          end
          
          def rectangle_gradient_parameter_names
            [:x, :y, :width, :height, :vertical]
          end
          
          def rectangle_parameter_names
            [:x, :y, :width, :height]
          end
          
          def rectangle_rectangle_parameter_names
            # this receives a Rectangle object
            [:rectangle]
          end
          
          def set_parameter_attribute(attribute_name, *args)
            return super(attribute_name, *args) if @parameter_names.to_a.map(&:to_s).include?(attribute_name.to_s)
            if rectangle_parameter_names.map(&:to_s).include?(attribute_name.to_s)
              @parameter_names = rectangle_parameter_names
            elsif rectangle_round_parameter_names.map(&:to_s).include?(attribute_name.to_s)
              @parameter_names = rectangle_round_parameter_names
            elsif rectangle_gradient_parameter_names.map(&:to_s).include?(attribute_name.to_s)
              @parameter_names = rectangle_gradient_parameter_names
            elsif rectangle_rectangle_parameter_names.map(&:to_s).include?(attribute_name.to_s)
              @parameter_names = rectangle_rectangle_parameter_names
            end
            super(attribute_name, *args)
          end
                
          def element
            'rect'
          end
          
          def dom
            shape_id = id
            shape_class = name
            @dom ||= xml {
              rect(id: shape_id, class: shape_class, x: @args[0], y: @args[1], width: @args[2], height: @args[3], rx: @args[4].to_f/2.0, ry: @args[5].to_f/2.0)
            }.to_s
          end
          
        end
      end
    end
  end
end
