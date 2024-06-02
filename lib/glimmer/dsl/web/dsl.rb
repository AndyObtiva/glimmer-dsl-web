# Copyright (c) 2023-2024 Andy Maleh
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

require 'glimmer/dsl/engine'
require 'glimmer/dsl/web/element_expression'
require 'glimmer/dsl/web/formatting_element_expression'
require 'glimmer/dsl/web/listener_expression'
require 'glimmer/dsl/web/property_expression'
require 'glimmer/dsl/web/span_expression'
require 'glimmer/dsl/web/style_expression'
require 'glimmer/dsl/web/bind_expression'
require 'glimmer/dsl/web/data_binding_expression'
require 'glimmer/dsl/web/content_data_binding_expression'
require 'glimmer/dsl/web/shine_data_binding_expression'
require 'glimmer/dsl/web/component_expression'
require 'glimmer/dsl/web/observe_expression'

module Glimmer
  module DSL
    module Web
      Engine.add_dynamic_expressions(
       Web,
       %w[
         component
         listener
         data_binding
         property
         content_data_binding
         shine_data_binding
         style
         formatting_element
       ]
      )
    end
  end
end
