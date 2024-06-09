require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/web/general_element_expression'

module Glimmer
  module DSL
    module Web
      class AExpression < StaticExpression
        include GeneralElementExpression
        
        def can_interpret?(parent, keyword, *args, &block)
          (parent.nil? ||
            (parent.respond_to?(:keyword) && parent.keyword != 'p'))
        end
      end
    end
  end
end
