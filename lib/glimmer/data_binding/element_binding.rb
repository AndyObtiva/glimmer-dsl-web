require 'glimmer/data_binding/observable'
require 'glimmer/data_binding/observer'

module Glimmer
  module DataBinding
    class ElementBinding
      include Observable
      include Observer
      
      attr_reader :element, :property, :translator, :sub_property
      def initialize(element, property, translator: nil)
        @element = element
        if (property_parts = property.to_s.match(Glimmer::Web::ElementProxy::REGEX_CLASS_NAME_SUB_PROPERTY))
          @property, @sub_property = property_parts.to_a.drop(1)
        elsif (property_parts = property.to_s.match(Glimmer::Web::ElementProxy::REGEX_STYLE_SUB_PROPERTY))
          @property, @sub_property = property_parts.to_a.drop(1)
          @sub_property = @sub_property.gsub('_', '-')
        else
          @property = property
        end
        @translator = translator

        if @element.respond_to?(:remove)
          unregister_handler = lambda { |dispose_event| unregister_all_observables }
          @element.handle_observation_request('on_remove', unregister_handler)
        end
      end
      
      def call(value)
        evaluated_property_value = evaluate_property
        converted_value = @translator&.call(value, evaluated_property_value) || value
        if converted_value != evaluated_property_value
          if @sub_property
            if @property.to_s == 'class_name'
              @element.class_name_included(@sub_property, converted_value)
            elsif @property.to_s == 'style'
              @element.style_property(@sub_property, converted_value)
            end
          else
            @element.send("#{@property}=", converted_value)
          end
        end
      end
      
      def evaluate_property
        if @sub_property
          if @property.to_s == 'class_name'
            @element.class_name_included(@sub_property)
          elsif @property.to_s == 'style'
            @element.style_property(@sub_property)
          end
        else
          @element.send(@property)
        end
      end
    end
  end
end
