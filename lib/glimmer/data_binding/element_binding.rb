require 'glimmer/data_binding/observable'
require 'glimmer/data_binding/observer'

module Glimmer
  module DataBinding
    class ElementBinding
      include Observable
      include Observer

      attr_reader :element, :property
      def initialize(element, property, translator = nil)
        @element = element
        @property = property
        @translator = translator

        # TODO implement automatic cleanup upon calling element.remove
        # Alternatively, have this be built into ElementProxy and remove this code
#         if @element.respond_to?(:dispose)
#           @element.on_widget_disposed do |dispose_event|
#             unregister_all_observables
#           end
#         end
      end
      
      def call(value)
        evaluated_property_value = evaluate_property
        converted_value = @translator&.call(value, evaluated_property_value) || value
        @element.send("#{@property}=", converted_value) unless converted_value == evaluated_property_value
      end
      
      def evaluate_property
        @element.send(@property)
      end
    end
  end
end
