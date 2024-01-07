require 'glimmer/dsl/expression'

require 'glimmer/web/formatting_element_proxy'

module Glimmer
  module DSL
    module Web
      class FormattingElementExpression < Expression
        def can_interpret?(parent, keyword, *args, &block)
          Glimmer::Web::FormattingElementProxy.keyword_supported?(keyword, parent: parent)
        end
        
        def interpret(parent, keyword, *args, &block)
          Glimmer::Web::FormattingElementProxy.format(keyword, *args, &block)
        end
      end
    end
  end
end
