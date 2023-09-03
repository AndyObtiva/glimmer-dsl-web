require 'glimmer/dsl/expression'
require 'glimmer/data_binding/model_binding'
require 'glimmer/data_binding/table_items_binding'
require 'glimmer/swt/table_proxy'

module Glimmer
  module DSL
    module Opal
      #Depends on BindCommandHandler and TableColumnPropertiesDataBindingCommandHandler
      class TableItemsDataBindingExpression < Expression
        def can_interpret?(parent, keyword, *args, &block)
          keyword == "items" and
            block.nil? and
            parent.is_a?(Glimmer::SWT::TableProxy) and
            args.size.between?(1, 2) and
            args[0].is_a?(DataBinding::ModelBinding) and
            args[0].evaluate_property.is_a?(Array) and
            (args[1].nil? or args[1].is_a?(Array))
        end
  
        def interpret(parent, keyword, *args, &block)
          model_binding = args[0]
          column_properties = args[1]
          DataBinding::TableItemsBinding.new(parent, model_binding, column_properties)
        end
      end
    end
  end
end
