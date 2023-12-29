require 'glimmer/dsl/engine'
# Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f}
require 'glimmer/dsl/web/element_expression'
require 'glimmer/dsl/web/listener_expression'
require 'glimmer/dsl/web/property_expression'

module Glimmer
  module DSL
    module Web
      # TODO implement all those expressions
#        %w[
#          listener
#          data_binding
#          property
#          shine_data_binding
#          element
#        ]
      Engine.add_dynamic_expressions(
       Web,
       %w[
         listener
         property
         element
       ]
      )
    end
  end
end
