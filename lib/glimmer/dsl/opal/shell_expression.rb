require 'glimmer/dsl/static_expression'
require 'glimmer/dsl/top_level_expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/shell_proxy'
require 'glimmer/swt/make_shift_shell_proxy'
require 'glimmer/ui/custom_shell'
require 'glimmer/dsl/opal/custom_widget_expression'

module Glimmer
  module DSL
    module Opal
      class ShellExpression < StaticExpression
        include TopLevelExpression
        include ParentExpression

        def interpret(parent, keyword, *args, &block)
          if Glimmer::UI::CustomShell.requested_and_not_handled?
            parameters = Glimmer::UI::CustomShell.request_parameter_string.split("&").map {|str| str.split("=")}.to_h
            `history.pushState(#{parameters.merge('custom_shell_handled' => 'true')}, document.title, #{"?#{Glimmer::UI::CustomShell.encoded_request_parameter_string}&custom_shell_handled=true"})`
            custom_shell_keyword = parameters.delete('custom_shell')
            CustomWidgetExpression.new.interpret(nil, custom_shell_keyword, *[parameters])
            `history.pushState(#{parameters.reject {|k,v| k == 'custom_shell_handled'}}, document.title, #{"?#{Glimmer::UI::CustomShell.encoded_request_parameter_string.sub('&custom_shell_handled=true', '')}"})`
            # just a placeholder that has an open method # TODO return an actual CustomShell in the future that does the work happening above in the #open method
            Glimmer::SWT::MakeShiftShellProxy.new
          else
            Glimmer::SWT::ShellProxy.new(args)
          end
        end
        
        def add_content(parent, keyword, *args, &block)
          super(parent, keyword, *args, &block)
          parent.post_add_content
        end
      end
    end
  end
end
