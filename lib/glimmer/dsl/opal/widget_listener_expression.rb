require 'glimmer/dsl/expression'

module Glimmer
  module DSL
    module Opal
      class WidgetListenerExpression < Expression

        def can_interpret?(parent, keyword, *args, &block)
          Glimmer::Config.logger.debug {"keyword starts with on_: #{keyword.start_with?('on_')}"}
          return false unless keyword.start_with?('on_')
          # TODO activate the following lines and test them
#           widget_or_display_parentage = parent.respond_to?(:swt_widget) || parent.is_a?(Glimmer::SWT::DisplayProxy)
#           Glimmer::Config.logger.debug {"parent #{parent} is a widget or display: #{widget_or_display_parentage}"}
#           return false unless widget_or_display_parentage
#           Glimmer::Config.logger.debug {"block exists?: #{!block.nil?}"}
#           raise Glimmer::Error, "Listener is missing block for keyword: #{keyword}" unless block_given?
#           Glimmer::Config.logger.debug {"args are empty?: #{args.empty?}"}
#           raise Glimmer::Error, "Invalid listener arguments for keyword: #{keyword}(#{args})" unless args.empty?
#           result = parent.can_handle_observation_request?(keyword)
#           Glimmer::Config.logger.debug {"can add listener? #{result}"}
#           raise Glimmer::Error, "Invalid listener keyword: #{keyword}" unless result
          true
        end

        def interpret(parent, keyword, *args, &block)
          parent.handle_observation_request(keyword, block)
        end
      end
    end
  end
end
