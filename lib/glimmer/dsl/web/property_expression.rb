require 'glimmer/dsl/expression'

require 'glimmer/web/element_proxy'

module Glimmer
  module DSL
    module Web
      class PropertyExpression < Expression
        def can_interpret?(parent, keyword, *args, &block)
          # TODO add this condition once formatting elements become normal elements
          # or delete this line if no longer needed:
          # parent.is_a?(Glimmer::Web::FormattingElementProxy) ||
          # Also, consider removing type check altogether (to generalize if good idea)
          (
            parent.is_a?(Glimmer::Web::ElementProxy) ||
            parent.is_a?(Glimmer::Web::Component)
          ) and
            (!args.empty?) and
            parent.respond_to?("#{keyword}=") and
            block.nil?
        end

        def interpret(parent, keyword, *args, &block)
          parent.send("#{keyword}=", *args)
          args
        end
      end
    end
  end
end
