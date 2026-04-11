require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/top_level_expression'
require 'glimmer/dsl/observe_expression'
require 'glimmer/web/component'

module Glimmer
  module DSL
    module SWT
      class ObserveExpression < StaticExpression
        include TopLevelExpression
        include Glimmer::DSL::ObserveExpression

        def interpret(parent, keyword, *args, &block)
          observer_registration = super(parent, keyword, *args, &block)
          Glimmer::Web::Component.interpretation_stack.last&.observer_registrations&.push(observer_registration)
          observer_registration
        end
      end
    end
  end
end
