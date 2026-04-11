require 'glimmer/dsl/expression'

module Glimmer
  module DSL
    module Web
      class ContentDataBindingExpression < Expression
        def can_interpret?(parent, keyword, *args, &block)
          keyword == 'content' &&
            block_given? &&
            args.size > 0 &&
            parent&.respond_to?(:bind_content)
        end
  
        def interpret(parent, keyword, *args, &block)
          parent.bind_content(*args, &block)
        end
      end
    end
  end
end
