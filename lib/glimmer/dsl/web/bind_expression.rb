require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/bind_expression'
require 'glimmer/data_binding/model_binding'

module Glimmer
  module DSL
    module Web
      # Responsible for setting up the return value of the bind keyword (command symbol)
      # as a ModelBinding. It is then used by other data-binding expressions
      class BindExpression < StaticExpression
        include Glimmer::DSL::BindExpression
      end
    end
  end
end
