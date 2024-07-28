require 'glimmer/dsl/expression'

module Glimmer
  module DSL
    module Web
      class InlineStyleDataBindingExpression < Expression
        def can_interpret?(parent, keyword, *args, &block)
          keyword == 'style' &&
            block.nil? &&
            args.size == 1 &&
            textual?(args.first)
        end
        
        def interpret(parent, keyword, *args, &block)
          parent_attribute = "#{keyword}_#{args.first.to_s.underscore}"
          Glimmer::DataBinding::Shine.new(parent, parent_attribute)
        end
      end
    end
  end
end
