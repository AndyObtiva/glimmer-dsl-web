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
