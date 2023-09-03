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
require 'glimmer/swt/image_proxy'
# require 'glimmer/swt/transform_proxy'

module Glimmer
  module SWT
    module Custom
      class Shape
        class Image < Shape
          def parameter_names
            if image_whole_parameter_names.size == @args.size
              @parameter_names = image_whole_parameter_names
            elsif image_part_parameter_names.size == @args.size
              @parameter_names = image_part_parameter_names
            end
            @parameter_names || image_whole_parameter_names
          end
        
          def possible_parameter_names
            (image_whole_parameter_names + image_part_parameter_names).uniq
          end
          
          def image_part_parameter_names
            [:image, :src_x, :src_y, :src_width, :src_height, :dest_x, :dest_y, :dest_width, :dest_height]
          end
          
          def image_whole_parameter_names
            [:image, :x, :y]
          end
          
          def set_parameter_attribute(attribute_name, *args)
            if @parameter_names.to_a.map(&:to_s).include?(attribute_name.to_s)
              super(attribute_name, *args)
              build_dom
              reattach(dom_element)
              return
            end
            ####TODO refactor and improve this method through meta-programming (and share across other shapes)
            if image_whole_parameter_names.map(&:to_s).include?(attribute_name.to_s)
              @parameter_names = image_whole_parameter_names
            elsif image_part_parameter_names.map(&:to_s).include?(attribute_name.to_s)
              @parameter_names = image_part_parameter_names
            end
            super(attribute_name, *args)
          end
              
          def reattach(old_element)
            old_element.attr('href', Element[@dom].attr('href'))
            old_element.attr('x', Element[@dom].attr('x'))
            old_element.attr('y', Element[@dom].attr('y'))
            old_element.attr('width', Element[@dom].attr('width'))
            old_element.attr('height', Element[@dom].attr('height'))
          end
        
          def element
            'image'
          end
          
          def dom
            shape_id = id
            shape_class = name
            href = @args[0].is_a?(Glimmer::SWT::ImageProxy) ? @args[0].file_path : @args[0]
            width = @args[0].is_a?(Glimmer::SWT::ImageProxy) ? @args[0].width : nil
            height = @args[0].is_a?(Glimmer::SWT::ImageProxy) ? @args[0].height : nil
            @dom ||= xml {
              image(id: shape_id, class: shape_class, href: href, x: @args[1], y: @args[2], width: width, height: height)
            }.to_s
          end
          
        end
      end
    end
  end
end
