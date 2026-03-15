require 'glimmer/dsl/expression'
require 'glimmer/dsl/web/general_element_expression'

require 'glimmer/web/element_proxy'

module Glimmer
  module DSL
    module Web
      class ElementExpression < Expression
        include GeneralElementExpression
        
        REGEXP_ARG_TYPE_STRING = /(String)*(Hash)?/
        
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
              valid_element_args?(args)
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
        
        def valid_element_args?(args)
          arg_types = args.map do |arg|
            if arg.is_a?(String)
              'String'
            elsif arg.is_a?(Hash)
              'Hash'
            else
              'Unsupported'
            end
          end
          arg_type_string = arg_types.join
          arg_type_string.match(REGEXP_ARG_TYPE_STRING)
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
