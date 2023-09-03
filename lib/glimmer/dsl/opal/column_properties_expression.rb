require 'glimmer/dsl/static_expression'
require 'glimmer/swt/table_proxy'

module Glimmer
  module DSL
    module Opal
      # Responsible for providing a readable keyword (command symbol) to capture
      # and return column properties for use in TreeItemsDataBindingCommandHandler
      class ColumnPropertiesExpression < StaticExpression
        def can_interpret?(parent, keyword, *args, &block)
          keyword == 'column_properties' and
            block.nil? and
            parent.is_a?(Glimmer::SWT::TableProxy)
        end
  
        def interpret(parent, keyword, *args, &block)
          args
        end
      end
    end
  end
end
