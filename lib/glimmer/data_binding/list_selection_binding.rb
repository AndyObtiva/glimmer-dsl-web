require 'glimmer/data_binding/observable'
require 'glimmer/data_binding/observer'

module Glimmer
  module DataBinding
    # SWT List element selection binding
    class ListSelectionBinding
      include Glimmer
      include Observable
      include Observer

      attr_reader :element_proxy

      PROPERTY_TYPE_UPDATERS = {
        :string => lambda { |element_proxy, value| element_proxy.select(element_proxy.index_of(value.to_s)) },
        :array => lambda { |element_proxy, value| element_proxy.selection=(value || []) }
      }

      PROPERTY_EVALUATORS = {
        :string => lambda do |selection_array|
          return nil if selection_array.empty?
          selection_array[0]
        end,
        :array => lambda do |selection_array|
          selection_array
        end
      }

      # Initialize with list element and property_type
      # property_type :string represents default list single selection
      # property_type :array represents list multi selection
      def initialize(element_proxy, property_type)
        property_type = :string if property_type.nil? or property_type == :undefined
        @element_proxy = element_proxy
        @property_type = property_type
        @element_proxy.on_widget_disposed do |dispose_event|
          unregister_all_observables
        end
      end

      def call(value)
        PROPERTY_TYPE_UPDATERS[@property_type].call(@element_proxy, value) unless !evaluate_property.is_a?(Array) && evaluate_property == value
      end

      def evaluate_property
        selection_array = @element_proxy.selection.to_a #TODO refactor send('selection') into proper method invocation
        PROPERTY_EVALUATORS[@property_type].call(selection_array)
      end
    end
  end
end
