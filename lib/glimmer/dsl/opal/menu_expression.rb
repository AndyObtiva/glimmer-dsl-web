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
require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/widget_proxy'
require 'glimmer/swt/menu_proxy'

module Glimmer
  module DSL
    module Opal
      class MenuExpression < StaticExpression
        include ParentExpression
        
        def can_interpret?(parent, keyword, *args, &block)
          initial_condition = (keyword == 'menu')
          if initial_condition
            if parent.is_a?(Glimmer::SWT::WidgetProxy)
              return true
            else
              raise Glimmer::Error, "menu may only be nested under a widget (like shell or another menu)!"
            end
          end
          false
        end
  
        def interpret(parent, keyword, *args, &block)
          Glimmer::SWT::MenuProxy.new(parent, args)
        end
        
        def add_content(parent, keyword, *args, &block)
          super(parent, keyword, *args, &block)
          parent.post_add_content
        end
        
      end
      
    end
    
  end
  
end
