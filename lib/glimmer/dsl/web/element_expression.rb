require 'glimmer/dsl/expression'
require 'glimmer/dsl/web/general_element_expression'

require 'glimmer/web/element_proxy'

module Glimmer
  module DSL
    module Web
      class ElementExpression < Expression
        include GeneralElementExpression
        
        def can_interpret?(parent, keyword, *args, &block)
          slot = keyword.to_s.to_sym
          Glimmer::Web::ElementProxy.keyword_supported?(keyword) &&
            (
              (
                args.empty? &&
                (
                  parent.nil? ||
                  !parent.respond_to?(:slot_elements) ||
                  !(parent.slot_elements.keys.include?(slot) || parent.slot_elements.keys.include?(slot.to_s))
                )
              ) ||
              args.size == 1 && args.first.is_a?(String) ||
              args.size == 1 && args.first.is_a?(Hash) ||
              args.size == 2 && args.first.is_a?(String) && args.last.is_a?(Hash)
            ) &&
            (
              keyword != 'title' ||
              parent.nil? ||
              parent.keyword == 'head'
            ) &&
            ( # ensure SVG keywords only live under SVG element (unless it's the SVG element itself)
              !Glimmer::Web::ElementProxy.svg_keyword_supported?(keyword) ||
              keyword == 'svg' ||
              parent.find_ancestor(include_self: true) { |ancestor| ancestor.keyword == 'svg' }
            )
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
