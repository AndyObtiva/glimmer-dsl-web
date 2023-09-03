require 'glimmer/dsl/expression'
require 'glimmer/swt/custom/shape'

module Glimmer
  module DSL
    module Opal
      class PropertyExpression < StaticExpression
        def can_interpret?(parent, keyword, *args, &block)
          parent and
            (!args.empty?) and
            parent.respond_to?(:set_attribute) and
            parent.respond_to?(keyword) and
            keyword and
            block.nil?
        end

        def interpret(parent, keyword, *args, &block)
          if keyword == 'text' # TODO move into property converters in element proxy
            args = [args.first.to_s.gsub('&', '')]
          end
          parent.set_attribute(keyword, *args)
          args.first.to_s
        end
      end
    end
  end
end
