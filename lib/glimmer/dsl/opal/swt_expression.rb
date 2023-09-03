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

require 'glimmer/dsl/static_expression'
require 'glimmer/swt/swt_proxy'

# TODO consider turning static keywords like bind into methods

module Glimmer
  module DSL
    module Opal
      # Responsible for returning SWT constant values
      #
      # Named SwtExpression (not SWTExpression) so that the DSL engine
      # discovers quickly by convention
      class SwtExpression < StaticExpression
        def can_interpret?(parent, keyword, *args, &block)
          block.nil? and
            args.size > 0
        end
  
        def interpret(parent, keyword, *args, &block)
          Glimmer::SWT::SWTProxy[*args]
        end
      end
    end
  end
end
