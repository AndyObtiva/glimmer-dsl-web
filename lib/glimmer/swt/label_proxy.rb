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

require 'glimmer/swt/widget_proxy'
# require 'glimmer/swt/image_proxy'

module Glimmer
  module SWT
    class LabelProxy < WidgetProxy
      attr_reader :text, :background_image, :image, :separator, :vertical
      alias separator? separator
      alias vertical? vertical
      
      def initialize(parent, args, block)
        @separator = args.detect { |arg| SWTProxy[arg] == SWTProxy[:separator] }
        @vertical = args.detect { |arg| SWTProxy[arg] == SWTProxy[:vertical] }
        super(parent, args, block)
      end
      
      def horizontal
        !vertical
      end
      alias horizontal? horizontal

      def text=(value)
        @text = value
        dom_element.html(html_text) unless @image
      end
      
      def html_text
        text && CGI.escape_html(text).gsub("\n", '<br />')
      end
      
      def image=(value)
        @image = value
        dom_element.html("<img src='#{@image}' />")
      end
      
      # background image is stretched by default
      def background_image=(value)
        @background_image = value
        dom_element.css('background-image', "url(#{@background_image})")
        dom_element.css('background-repeat', 'no-repeat')
        dom_element.css('background-size', 'cover')
      end
      
      def element
        'label'
      end
      
      def alignment
        if @alignment.nil?
          found_arg = nil
          @alignment = [:left, :center, :right].detect {|align| found_arg = args.detect { |arg| SWTProxy[align] == SWTProxy[arg] } }
          args.delete(found_arg)
        end
        @alignment
      end

      def alignment=(value)
        # TODO consider storing swt value in the future instead
        @alignment = value
        dom_element.css('text-align', @alignment.to_s)
      end
      
      def dom
        label_id = id
        label_class = name
        label_style = "text-align: #{alignment}; "
        label_style += "border-top: 1px solid rgb(207, 207, 207); " if separator? && horizontal?
        label_style += "border-right: 1px solid rgb(207, 207, 207); height: 100%; " if separator? && vertical?
        @dom ||= html {
          label(id: label_id, class: label_class, style: label_style) {
            html_text
          }
        }.to_s
      end
    end
  end
end
