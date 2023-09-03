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

require 'glimmer/ui/custom_widget'
require 'glimmer/swt/display_proxy'
require 'glimmer/error'

module Glimmer
  module UI
    module CustomShell
      include Glimmer::UI::CustomWidget
      
      module ClassMethods
        include Glimmer
        attr_reader :custom_shell
        
        def launch
          custom_shell = send(self.name.underscore.gsub('::', '__'))
          custom_shell.open
        end
      end
      
      class << self
        def included(klass)
          klass.extend(CustomWidget::ClassMethods)
          klass.extend(CustomShell::ClassMethods)
          klass.include(Glimmer)
          Glimmer::UI::CustomWidget.add_custom_widget_namespaces_for(klass)
          keyword = klass.name.split(':').last.underscore
          LocalStorage[keyword] = $LOADED_FEATURES.last
        end
        
        def request_parameter_string
          URI.decode_www_form_component(`document.location.href`.match(/\?(.*)$/).to_a[1].to_s)
        end
        
        def encoded_request_parameter_string
          `document.location.href`.match(/\?(.*)$/).to_a[1].to_s
        end
        
        def requested_and_not_handled?
          requested? && !request_parameter_string.include?('custom_shell_handled=true')
        end
        
        def requested?
          request_parameter_string.include?('custom_shell=')
        end
      end
      
      def initialize(parent, args, options, &content)
        super(parent, args, options, &content)
        body_root.set_data('custom_shell', self)
        body_root.set_data('custom_window', self)
        raise Error, 'Invalid custom shell body root! Must be a shell or another custom shell.' unless body_root.is_a?(Glimmer::SWT::ShellProxy) || body_root.is_a?(Glimmer::UI::CustomShell)
      end

      def open(async: true)
        work = lambda do
          body_root.open
        end
        if async
          Glimmer::SWT::DisplayProxy.instance.async_exec(&work)
        else
          work.call
        end
      end
      

      # DO NOT OVERRIDE. JUST AN ALIAS FOR `#open`. OVERRIDE `#open` INSTEAD.
      def show
        open
      end

      def close
        body_root.close
      end

      def hide
        body_root.hide
      end

      def visible?
        body_root.visible?
      end

      def start_event_loop
        body_root.start_event_loop
      end
    end
  end
end
