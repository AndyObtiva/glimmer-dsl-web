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

require 'glimmer/swt/latest_shell_proxy'
require 'glimmer/swt/latest_message_box_proxy'
require 'glimmer/swt/latest_dialog_proxy'
require 'glimmer/swt/display_proxy'

module Glimmer
  module DSL
    class Engine
      class << self
        def interpret_expression(expression, keyword, *args, &block)
          work = lambda do
            expression.interpret(parent, keyword, *args, &block).tap do |ui_object|
              add_content(ui_object, expression, keyword, *args, &block)
              dsl_stack.pop
            end
          end
          if ['shell', 'message_box', 'dialog'].include?(keyword) && Glimmer::SWT::DisplayProxy.instance.shells.empty?
            Document.ready? do
              Glimmer::SWT::DisplayProxy.instance.async_exec(&work)
            end
            Glimmer::SWT.const_get("Latest#{keyword.camelcase(:upper)}Proxy").new
          else
            work.call
          end
        end
      end
    end
  end
end
