require 'glimmer/dsl/engine'
require 'glimmer/dsl/web/element_expression'
require 'glimmer/dsl/web/listener_expression'
require 'glimmer/dsl/web/property_expression'
require 'glimmer/dsl/web/p_expression'
require 'glimmer/dsl/web/select_expression'
require 'glimmer/dsl/web/bind_expression'
require 'glimmer/dsl/web/data_binding_expression'
require 'glimmer/dsl/web/content_data_binding_expression'
require 'glimmer/dsl/web/shine_data_binding_expression'
require 'glimmer/dsl/web/component_expression'

module Glimmer
  module DSL
    module Web
      Engine.add_dynamic_expressions(
       Web,
       %w[
         component
         listener
         data_binding
         property
         content_data_binding
         shine_data_binding
         element
       ]
      )
    end
  end
end
