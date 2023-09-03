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

require 'glimmer/swt/shell_proxy'

module Glimmer
  module SWT
    class LatestShellProxy < ShellProxy
      def initialize
        # No Op
      end
      
      def method_missing(method, *args, &block)
        if latest_shell.nil?
          super(method, *args, &block)
        else
          latest_shell.send(method, *args, &block)
        end
      end
      
      def respond_to?(method_name, include_private = false)
        super(method_name, include_private) || latest_shell&.respond_to?(method_name, include_private)
      end
      
      def open
        Document.ready? do
          DisplayProxy.instance.async_exec {
            latest_shell&.open
          }
        end
      end
      
      def latest_shell
        @latest_shell ||= DisplayProxy.instance.shells.last
      end

    end
    
  end
  
end
