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

require 'glimmer/swt/grid_layout_proxy'
require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    class CompositeProxy < WidgetProxy
      def initialize(parent, args, block)
        super(parent, args, block)
        @layout = default_layout
      end
      
      def default_layout
        GridLayoutProxy.new(self, [])
      end
      
      def dom
        div_id = id
        div_style = css
        div_class = name
        @dom ||= html {
          div(id: div_id, class: div_class, style: div_style)
        }.to_s
      end
      
      def layout=(the_layout)
        @layout = the_layout
      end
      alias set_layout layout=
      alias setLayout layout=
      
      def get_layout
        @layout
      end
      alias getLayout get_layout #TODO consider pregenerating these aliases with an easy method in the future

      def pack(*args)
        # No Op (just a shim) TODO consider if it should be implemented
      end
      
      def layout​(changed = nil, all = nil)
        # TODO implement layout(changed = nil, all = nil) just as per SWT API
        @layout&.layout(self, changed)
      end
      
      # background image
      def background_image
        @background_image
      end
      
      # background image is stretched by default
      def background_image=(value)
        @background_image = value
        dom_element.css('background-image', "url(#{background_image})")
        dom_element.css('background-repeat', 'no-repeat')
        dom_element.css('background-size', 'cover')
      end
            
    end
    
  end
  
end
