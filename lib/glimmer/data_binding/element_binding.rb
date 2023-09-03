require 'glimmer/data_binding/observable'
require 'glimmer/data_binding/observer'

module Glimmer
  module DataBinding
    class ElementBinding
      # TODO consider renaming to WidgetBinding since it's no longer dealing with elements directly yet widgets instead
      include Glimmer
      include Observable
      include Observer

      attr_reader :element, :property
      def initialize(element, property, translator = nil)
        @element = element
        @property = property
        @translator = translator || proc {|value| value}

        # TODO see if this is needed in Opal
#         if @element.respond_to?(:dispose)
#           @element.on_widget_disposed do |dispose_event|
#             unregister_all_observables
#           end
#         end
      end
      
      def call(value)
        converted_value = translated_value = @translator.call(value)
        @element.set_attribute(@property, converted_value) unless evaluate_property == converted_value
      end
      
      def evaluate_property
        @element.send(@property)
      end
    end
  end
end
