# Copyright (c) 2020-2022 Andy Maleh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'glimmer'
require 'glimmer/dsl/expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/dsl/top_level_expression'
require 'glimmer/ui/custom_widget'
require 'glimmer/ui/custom_shell'
require 'glimmer/swt/make_shift_shell_proxy'
require 'glimmer/swt/custom/radio_group'
require 'glimmer/swt/custom/checkbox_group'

module Glimmer
  module DSL
    module Opal
      class CustomWidgetExpression < Expression
        # TODO Make custom widgets automatically generate static expressions
        include ParentExpression
        include TopLevelExpression

        def can_interpret?(parent, keyword, *args, &block)
          !!UI::CustomWidget.for(keyword)
        end
  
        def interpret(parent, keyword, *args, &block)
          begin
            require_path = LocalStorage[keyword]
            require(require_path) if require_path
          rescue => e
            Glimmer::Config.logger.debug e.message
          end
          custom_widget_class = UI::CustomWidget.for(keyword)
          # TODO clean code by extracting methods into CustomShell
          if !Glimmer::UI::CustomShell.requested? && custom_widget_class&.ancestors&.to_a.include?(Glimmer::UI::CustomShell)
            if Glimmer::SWT::DisplayProxy.instance.shells.empty? || Glimmer::SWT::DisplayProxy.open_custom_shells_in_current_window?
              custom_widget_class.new(parent, args, {}, &block)
            else
              options = args.last.is_a?(Hash) ? args.pop : {}
              options = options.merge('swt_style' => args.join(',')) unless args.join(',').empty?
              params = {
                'custom_shell' => keyword
              }.merge(options)
              param_string = params.to_a.map {|k, v| "#{k}=#{URI.encode_www_form_component(v)}"}.join('&')
              url = "#{`document.location.href`}?#{param_string}"
              `window.open(#{url})`
               # just a placeholder that has an open method # TODO return an actual CustomShell in the future that does the work happening above in the #open method
              Glimmer::SWT::MakeShiftShellProxy.new
            end
          else
            if Glimmer::UI::CustomShell.requested_and_not_handled?
              parameters = Glimmer::UI::CustomShell.request_parameter_string.split("&").map {|str| str.split("=")}.to_h
              `history.pushState(#{parameters.merge('custom_shell_handled' => 'true')}, document.title, #{"?#{Glimmer::UI::CustomShell.encoded_request_parameter_string}&custom_shell_handled=true"})`
              custom_shell_keyword = parameters.delete('custom_shell')
              CustomWidgetExpression.new.interpret(nil, custom_shell_keyword, *[parameters])
              `history.pushState(#{parameters.reject {|k,v| k == 'custom_shell_handled'}}, document.title, #{"?#{Glimmer::UI::CustomShell.encoded_request_parameter_string.sub('&custom_shell_handled=true', '')}"})`
              # just a placeholder that has an open method # TODO return an actual CustomShell in the future that does the work happening above in the #open method
              Glimmer::SWT::MakeShiftShellProxy.new
            else
              custom_widget_class&.new(parent, args, {}, &block)
            end
          end
        end
        
        # TODO delete if no longer needed
#         def add_content(parent, &content)
#           content.call(parent) if parent.is_a?(Glimmer::SWT::ShellProxy) || parent.is_a?(Glimmer::UI::CustomShell)
#         end
  
        def add_content(parent, keyword, *args, &block)
          return unless parent.is_a?(Glimmer::UI::CustomWidget)
          # TODO consider avoiding source_location since it does not work in Opal
          if block.source_location && (block.source_location == parent.content&.__getobj__&.source_location)
            parent.content.call(parent) unless parent.content.called?
          else
            super
          end
        end
      end
    end
  end
end
