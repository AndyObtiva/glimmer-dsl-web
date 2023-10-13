require 'glimmer/dsl/engine'
# Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f}
require 'glimmer/dsl/web/element_expression'

module Glimmer
  module DSL
    module Web
      # TODO implement all those expressions
#        %w[
#          event_listener
#          data_binding
#          attribute
#          shine_data_binding
#          element
#        ]
      Engine.add_dynamic_expressions(
       Web,
       %w[
         element
       ]
      )
    end
  end
end
