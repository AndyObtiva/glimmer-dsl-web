require 'glimmer/dsl/expression'

module Glimmer
  module DSL
    module Web
      class ListenerExpression < Expression
        def can_interpret?(parent, keyword, *args, &block)
          puts 'ListenerExpression#can_interpret?'
          puts 'keyword'
          puts keyword
          parent and
            parent.respond_to?(:can_handle_observation_request?) and
            parent.can_handle_observation_request?(keyword)
        end

        def interpret(parent, keyword, *args, &block)
          parent.handle_observation_request(keyword, block)
        end
      end
    end
  end
end
