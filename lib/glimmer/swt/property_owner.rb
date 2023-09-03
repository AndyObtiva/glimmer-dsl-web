module Glimmer
  module SWT
    # Adapts Glimmer UI classes to SWT JavaBean property owner classes (which are now adapted to Opal)
    module PropertyOwner
      # TODO consider adding has_attribute?
      
      def get_attribute(attribute_name)
        send(attribute_getter(attribute_name))
      end
    
      def set_attribute(attribute_name, *args)
        send(attribute_setter(attribute_name), *args) unless args.size == 1 && send(attribute_getter(attribute_name)) == args.first
      end
      
      def attribute_setter(attribute_name)
        "#{attribute_name.to_s.underscore}="
      end
      
      def attribute_getter(attribute_name)
        attribute_name.to_s.underscore
      end
    end
  end
end
