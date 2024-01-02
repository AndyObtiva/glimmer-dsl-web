require 'glimmer/dsl/expression'
require 'glimmer/dsl/web/general_element_expression'

require 'glimmer/web/element_proxy'

module Glimmer
  module DSL
    module Web
      class ElementExpression < Expression
        include GeneralElementExpression
        
        def can_interpret?(parent, keyword, *args, &block)
          Glimmer::Web::ElementProxy.keyword_supported?(keyword)
        end
      end
    end
  end
end
