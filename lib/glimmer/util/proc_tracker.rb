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

require 'delegate'

module Glimmer
  module Util
    # Decorator that provides tracking facilities for Ruby procs, tracking owner (string), invoked_form method name (symbol/string), and called? (boolean)
    class ProcTracker < DelegateClass(Proc)
      attr_reader :owner, :invoked_from
      
      def initialize(proc = nil, owner: nil, invoked_from: nil, &block)
        super(proc || block)
        @owner = owner
        @invoked_from = invoked_from
      end
      
      def call(*args)
        __getobj__.call(*args)
        @called = true
      end
      
      def called?
        !!@called
      end
      
      def respond_to?(method_name, include_private = false)
        %w[owner invoked_from called?].include?(method_name.to_s) || super(method_name, include_private)
      end
    end
  end
end
