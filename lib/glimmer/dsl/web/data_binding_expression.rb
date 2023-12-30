require 'glimmer/dsl/expression'
require 'glimmer/data_binding/model_binding'
require 'glimmer/data_binding/element_binding'

module Glimmer
  module DSL
    module Web
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
            args[0].is_a?(DataBinding::ModelBinding) and
            parent.respond_to?(:data_bind)
        end
  
        def interpret(parent, keyword, *args, &block)
          model_binding = args[0]
          property = keyword
          parent.data_bind(property, model_binding)
        end
      end
    end
  end
end
