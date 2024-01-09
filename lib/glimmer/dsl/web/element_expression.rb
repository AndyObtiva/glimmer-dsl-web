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

module Glimmer
  # Optimize performance through shortcut methods for all HTML elements that circumvent the DSL chain of responsibility
  element_expression = Glimmer::DSL::Web::ElementExpression.new
  Glimmer::Web::ElementProxy::ELEMENT_KEYWORDS.each do |keyword|
    Glimmer.send(:define_method, keyword) do |*args, &block|
      Glimmer::DSL::Engine.interpret_expression(element_expression, keyword, *args, &block)
    end
  end
end
