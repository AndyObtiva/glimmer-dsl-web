require 'glimmer/dsl/expression'

require 'glimmer/web/formatting_element_proxy'

module Glimmer
  module DSL
    module Web
      class FormattingElementExpression < Expression
        include GeneralElementExpression
        
        def can_interpret?(parent, keyword, *args, &block)
          Glimmer::Web::FormattingElementProxy.keyword_supported?(keyword, parent: parent) ||
            Glimmer::Web::ElementProxy.keyword_supported?(keyword)
        end
        
        def interpret(parent, keyword, *args, &block)
          if Glimmer::Web::FormattingElementProxy.keyword_supported?(keyword, parent: parent)
            Glimmer::Web::FormattingElementProxy.format(keyword, *args, &block)
          else
            super(parent, keyword, *args, &block)
          end
        end
      end
    end
  end
end

module Glimmer
  # Optimize performance through shortcut methods for all HTML formatting elements that circumvent the DSL chain of responsibility
  element_expression = Glimmer::DSL::Web::FormattingElementExpression.new
  Glimmer::Web::FormattingElementProxy::FORMATTING_ELEMENT_KEYWORDS.each do |keyword|
    Glimmer::DSL::Engine.static_expressions[keyword] ||= Concurrent::Hash.new
    element_expression_dsl = element_expression.class.dsl
    Glimmer::DSL::Engine.static_expressions[keyword][element_expression_dsl] = element_expression
    Glimmer.send(:define_method, keyword, &Glimmer::DSL::Engine::STATIC_EXPRESSION_METHOD_FACTORY.call(keyword))
  end
end
