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
        class Arc < Shape
          def parameter_names
            [:x, :y, :width, :height, :start_angle, :arc_angle]
          end
        
          def post_add_content
            @performing_post_add_content = true
            render
            @performing_post_add_content = false
          end
          
          def background=(value)
            super(value)
            self.foreground = value
          end

          def render(custom_parent_dom_element: nil, brand_new: false)
            return unless @performing_post_add_content
            the_parent_element = Native(`document.getElementById(#{parent.id})`)
            params = { type: `Two.Types.svg` }
            two = Native(`new Two(#{params})`)
            two.appendTo(the_parent_element)
            x = @args[0]
            y = @args[1]
            width = @args[2]
            height = @args[3]
            start_angle = -1*@args[4]
            arc_angle = -1*@args[5]
            end_angle = start_angle + arc_angle
            rx = width / 2.0
            ry = height / 2.0
            cx = x + rx
            cy = y + ry
            arc = two.makeArcSegment(cx, cy, 0, ry, 2*`Math.PI`*(start_angle)/360.0, 2*`Math.PI`*(end_angle)/360.0);
            arc.fill = background.to_css unless background.nil?
            arc.stroke = foreground.to_css unless foreground.nil?
            two.update
          end
                    
        end
      end
    end
  end
end
