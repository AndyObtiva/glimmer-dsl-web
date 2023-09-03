require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/opal/table_column'

module Glimmer
  module DSL
    module Opal
      class TableColumnExpression < StaticExpression
        include ParentExpression

        def interpret(parent, keyword, *args, &block)
          Glimmer::Opal::TableColumn.new(parent, args)
        end
      end
    end
  end
end
