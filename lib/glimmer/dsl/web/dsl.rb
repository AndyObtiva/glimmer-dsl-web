require 'glimmer/dsl/engine'
require 'glimmer/dsl/web/element_expression'
require 'glimmer/dsl/web/formatting_element_expression'
require 'glimmer/dsl/web/listener_expression'
require 'glimmer/dsl/web/property_expression'
require 'glimmer/dsl/web/a_expression'
require 'glimmer/dsl/web/span_expression'
require 'glimmer/dsl/web/style_element_expression'
require 'glimmer/dsl/web/inline_style_data_binding_expression'
require 'glimmer/dsl/web/class_name_inclusion_data_binding'
require 'glimmer/dsl/web/bind_expression'
require 'glimmer/dsl/web/data_binding_expression'
require 'glimmer/dsl/web/content_data_binding_expression'
require 'glimmer/dsl/web/shine_data_binding_expression'
require 'glimmer/dsl/web/component_expression'
require 'glimmer/dsl/web/component_slot_content_expression'
require 'glimmer/dsl/web/observe_expression'

module Glimmer
  module DSL
    module Web
      Engine.add_dynamic_expressions(
       Web,
       %w[
         listener
         style_element
         content_data_binding
         inline_style_data_binding
         class_name_inclusion_data_binding
         component_slot_content
         component
         formatting_element
         data_binding
         shine_data_binding
         property
       ]
      )
    end
  end
end
