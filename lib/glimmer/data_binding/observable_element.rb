module Glimmer
  module DataBinding
    module ObservableElement
      def method_missing(method, *args, &block)
        method_name = method.to_s
        if method_name.start_with?('on_')
          handle_observation_request(method_name, block)
        else
          super
        end
      end
    end
  end
end
