require 'glimmer/dsl/expression'

module Glimmer
  module DSL
    module Web
      class ClassNameInclusionDataBindingExpression < Expression
        def can_interpret?(parent, keyword, *args, &block)
          keyword == 'class_name' &&
            block.nil? &&
            args.size == 1 &&
            textual?(args.first)
        end
        
        def interpret(parent, keyword, *args, &block)
          parent_attribute = "#{keyword}_#{args.first.to_s}"
          Glimmer::DataBinding::Shine.new(parent, parent_attribute)
        end
      end
    end
  end
end
