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

module Kernel
  alias pi p
end

module Glimmer
  # Optimize performance through shortcut methods for all HTML elements that circumvent the DSL chain of responsibility
  element_expression = Glimmer::DSL::Web::ElementExpression.new
  (Glimmer::Web::ElementProxy::ELEMENT_KEYWORDS - ['a', 'span', 'style']).each do |keyword|
    Glimmer::DSL::Engine.static_expressions[keyword] ||= Concurrent::Hash.new
    element_expression_dsl = element_expression.class.dsl
    Glimmer::DSL::Engine.static_expressions[keyword][element_expression_dsl] = element_expression
    Glimmer.send(:define_method, keyword, &Glimmer::DSL::Engine::STATIC_EXPRESSION_METHOD_FACTORY.call(keyword))
  end
end
