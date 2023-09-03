require 'glimmer/dsl/expression'
require 'glimmer/data_binding/model_binding'
require 'glimmer/data_binding/element_binding'

module Glimmer
  module DSL
    module Opal
      # Responsible for wiring two-way data-binding for text and selection properties
      # on Text, Button, and Spinner elements.
      # Does so by using the output of the bind(model, property) command in the form
      # of a ModelBinding, which is then connected to an anonymous element observer
      # (aka element_data_binder as per element_data_binders array)
      #
      # Depends on BindCommandHandler
      class DataBindingExpression < Expression
        def can_interpret?(parent, keyword, *args, &block)
          args.size == 1 and
            args[0].is_a?(DataBinding::ModelBinding)
        end
  
        def interpret(parent, keyword, *args, &block)
          model_binding = args[0]
          element_binding_parameters = [parent, keyword]
          element_binding = DataBinding::ElementBinding.new(*element_binding_parameters)
          element_binding.call(model_binding.evaluate_property)
          #TODO make this options observer dependent and all similar observers in element specific data binding handlers
          element_binding.observe(model_binding)
          # TODO simplify this logic and put it where it belongs
          parent.add_observer(model_binding, keyword) if parent.respond_to?(:add_observer)
        end
      end
    end
  end
end
