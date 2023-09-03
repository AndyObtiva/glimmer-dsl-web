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
        class Text < Shape
          def parameter_names
            if text_parameter_names.size == @args.size
              @parameter_names = text_parameter_names
            elsif text_transparent_parameter_names.size == @args.size
              @parameter_names = text_transparent_parameter_names
            elsif text_flags_parameter_names.size == @args.size
              @parameter_names = text_flags_parameter_names
            end
            @parameter_names || text_parameter_names
          end
          
          def possible_parameter_names
            # TODO refactor and improve this method through meta-programming (and share across other shapes)
            (text_parameter_names + text_transparent_parameter_names + text_flags_parameter_names).uniq
          end
          
          def text_parameter_names
            [:string, :x, :y]
          end
          
          def text_transparent_parameter_names
            [:string, :x, :y, :is_transparent]
          end
          
          def text_flags_parameter_names
            [:string, :x, :y, :flags]
          end
          
          def set_parameter_attribute(attribute_name, *args)
            if @parameter_names.to_a.map(&:to_s).include?(attribute_name.to_s)
              super(attribute_name, *args)
              build_dom
              reattach(dom_element)
              return
            end
            if text_parameter_names.map(&:to_s).include?(attribute_name.to_s)
              @parameter_names = text_parameter_names
            elsif text_transparent_parameter_names.map(&:to_s).include?(attribute_name.to_s)
              @parameter_names = text_transparent_parameter_names
            elsif text_flags_parameter_names.map(&:to_s).include?(attribute_name.to_s)
              @parameter_names = text_flags_parameter_names
            end
            super(attribute_name, *args)
          end
          
          def reattach(old_element)
            old_element.attr('x', Element[@dom].attr('x'))
            old_element.attr('y', Element[@dom].attr('y'))
            old_element.text(Element[@dom].html)
          end
          
          def background=(value)
            # TODO override background= to fill a rectangle containing text, matching its size
            # For now, disable background when foreground is not set
            super(value) unless foreground.nil?
          end
        
          def foreground=(value)
            super(value)
            self.background = value
          end

          def element
            'text'
          end
          
          def dom
            shape_id = id
            shape_class = name
            @dom ||= xml {
              tag(:_name => 'text', id: shape_id, class: shape_class, x: @args[1], y: @args[2]) {
                @args[0]
              }
            }.to_s
          end
          
        end
        String = Text
      end
    end
  end
end
