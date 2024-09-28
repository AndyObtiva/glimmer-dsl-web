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

require 'glimmer'
require 'glimmer/dsl/expression'
require 'glimmer/web/component'

module Glimmer
  module DSL
    module Web
      class ComponentSlotContentExpression < Expression
        def can_interpret?(parent, keyword, *args, &block)
          component = parent.is_a?(Glimmer::Web::Component) ? parent : parent&.ancestor_component
          slot = keyword.to_s
          block_given? &&
            !component.nil? &&
            (
              component.slot_elements.keys.include?(slot) ||
              component.slot_elements.keys.include?(slot.to_sym)
            )
        end
  
        def interpret(parent, keyword, *args, &block)
          slot = keyword.to_s
          component = parent.is_a?(Glimmer::Web::Component) ? parent : parent.ancestor_component
          if slot == 'markup_root_slot'
            component.content(slot: slot.to_sym, &block)
          else
            slot_element = component.slot_elements[slot] || component.slot_elements[slot.to_sym]
            slot_element.content(&block)
          end
        end
      end
    end
  end
end
