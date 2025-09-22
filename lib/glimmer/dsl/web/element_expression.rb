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
              # TODO adjust this code to accept value-less attributes (Symbols)
#               args.size == 1 && args.first.is_a?(String) || # TODO consider refactoring to well named method that explain what is happening here
              # TODO args size 1 and Symbol only
#               args.size == 1 && args.first.is_a?(Symbol) ||
#               args.size == 1 && args.first.is_a?(Hash) ||
#               args.size == 2 && args.first.is_a?(String) && args.last.is_a?(Hash)
              # TODO args size 2 : Symbol or Hash
              # TODO args size 2 : String or Symbol
              # TODO args size 2 : Symbols only
              # TODO consider rewriting those checks to avoid looking into args.size, and instead look into
              # whether we start with a String, Symbol, or Hash,
              # Maybe, consider using a Regex that checks what's there as StringSymbolHash, StringSymbolSymbolHash, etc...
              # if we start with String, we follow by one or more Symbols, or by a Hash
              # if we start with Symbol, we follow by more Symbols or Hash
              # Otherwise, we start by Hash (no String/Symbol)
              # args.size > 1 && args.first.is_a?(String) && args.last.is_a?(Hash)
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
          # TODO i might be to simplify this implementation given that there is no worry about Symbol anymore. Refactor!!!
          # TODO we might need to map classes manually to avoid consumers using subclasses breaking this
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
