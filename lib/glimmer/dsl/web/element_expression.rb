require 'glimmer/dsl/expression'
require 'glimmer/dsl/web/general_element_expression'

module Glimmer
  module DSL
    module Web
      class ElementExpression < Expression
        include GeneralElementExpression
        
        def can_interpret?(parent, keyword, *args, &block)
          # TODO automatically pass parent option as element if not passed instead of rejecting elements without a paraent nor root
          # TODO raise a proper error if root is an element that is not found (maybe do this in model)
          !keyword.to_s.start_with?('on')
        end
      end
    end
  end
end
