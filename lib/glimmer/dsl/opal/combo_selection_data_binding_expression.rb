require 'glimmer/dsl/expression'
require 'glimmer/data_binding/model_binding'
require 'glimmer/data_binding/element_binding'
require 'glimmer/swt/combo_proxy'

module Glimmer
  module DSL
    module Opal
      class ComboSelectionDataBindingExpression < Expression
        def can_interpret?(parent, keyword, *args, &block)
          keyword == 'selection' and
            block.nil? and
            (parent.is_a?(Glimmer::SWT::ComboProxy) || parent.is_a?(Glimmer::SWT::CComboProxy)) and
            args.size == 1 and
            args[0].is_a?(DataBinding::ModelBinding) and
            args[0].evaluate_options_property.is_a?(Array)
        end
  
        def interpret(parent, keyword, *args, &block)
          model_binding = args[0]
  
          #TODO make this options observer dependent and all similar observers in element specific data binding handlers
          # TODO consider delegating some of this work
          element_binding = DataBinding::ElementBinding.new(parent, 'items')
          element_binding.call(model_binding.evaluate_options_property)
          model = model_binding.base_model
          element_binding.observe(model, model_binding.options_property_name)
  
          element_binding = DataBinding::ElementBinding.new(parent, 'text')
          element_binding.call(model_binding.evaluate_property)
          element_binding.observe(model, model_binding.property_name_expression)
  
          parent.on_widget_selected do
            model_binding.call(element_binding.evaluate_property)
          end
        end
      end
    end
  end
end
