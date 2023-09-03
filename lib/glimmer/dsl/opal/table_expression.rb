require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/table_proxy'

module Glimmer
  module DSL
    module Opal
      class TableExpression < StaticExpression
        include ParentExpression

        def interpret(parent, keyword, *args, &block)
          Glimmer::SWT::TableProxy.new(parent, args)
        end
      end
    end
  end
end
