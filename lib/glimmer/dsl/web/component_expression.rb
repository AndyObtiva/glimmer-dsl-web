require 'glimmer/dsl/parent_expression'
require 'glimmer/web/component'

module Glimmer
  module DSL
    module Web
      class ComponentExpression < Expression
        include ParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          Glimmer::Web::Component.for(keyword)
        end
  
        def interpret(parent, keyword, *args, &block)
          component_class = Glimmer::Web::Component.for(keyword)
          component_class.new(parent, args, {}, &block)
        end
  
        def add_content(parent, keyword, *args, &block)
          # TODO consider avoiding source_location since it does not work in Opal
          if block.source_location && (block.source_location == parent.content&.__getobj__&.source_location)
            parent.content.call(parent) unless parent.content.called?
          else
            if parent.default_slot
              slot = parent.default_slot
              slot_element = parent.slot_elements[slot]
              slot_element&.content(&block)
            else
              super(parent, keyword, *args, &block)
            end
          end
          parent.post_add_content
        end
      end
    end
  end
end
