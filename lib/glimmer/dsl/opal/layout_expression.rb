require 'glimmer/dsl/expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/layout_proxy'

module Glimmer
  module DSL
    module Opal
      class LayoutExpression < Expression
        include ParentExpression

        def can_interpret?(parent, keyword, *args, &block)
          (parent.is_a?(Glimmer::SWT::CompositeProxy) or (parent.is_a?(Glimmer::UI::CustomWidget) and parent.body_root.is_a?(Glimmer::SWT::CompositeProxy))) and
            Glimmer::SWT::LayoutProxy.layout_exists?(keyword)
        end

        def interpret(parent, keyword, *args, &block)
          Glimmer::SWT::LayoutProxy.for(keyword, parent, args)
        end
      end
    end
  end
end
