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
