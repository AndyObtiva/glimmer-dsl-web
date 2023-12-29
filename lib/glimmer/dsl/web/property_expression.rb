require 'glimmer/dsl/expression'

require 'glimmer/web/element_proxy'

module Glimmer
  module DSL
    module Web
      class PropertyExpression < Expression
        def can_interpret?(parent, keyword, *args, &block)
          parent.is_a?(Glimmer::Web::ElementProxy) and
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
