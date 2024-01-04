require 'glimmer/dsl/parent_expression'
require 'glimmer/web/component'

module Glimmer
  module DSL
    module Web
      class ComponentExpression < Expression
        include ParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          !!Glimmer::Web::Component.for(keyword)
        end
  
        def interpret(parent, keyword, *args, &block)
          custom_widget_class = Glimmer::Web::Component.for(keyword)
          custom_widget_class.new(parent, args, {}, &block)
        end
  
        def add_content(parent, keyword, *args, &block)
          # TODO consider avoiding source_location since it does not work in Opal
          if block.source_location && (block.source_location == parent.content&.__getobj__&.source_location)
            parent.content.call(parent) unless parent.content.called?
          else
            super
          end
        end
      end
    end
  end
end
