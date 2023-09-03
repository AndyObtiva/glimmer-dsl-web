require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    # Adapter for org.eclipse.swt.widgets.Group
    #
    # Follows Adapter Pattern
    class GroupProxy < CompositeProxy
      attr_reader :text
      
      def text=(value)
        @text = value
        if @text.nil?
          legend_dom_element.add_class('hide')
        else
          legend_dom_element.remove_class('hide')
        end
        legend_dom_element.html(@text)
      end
      
      def element
        'fieldset'
      end
      
      def legend_dom_element
        dom_element.find('legend')
      end
      
      def dom
        @dom ||= html {
          fieldset(id: id, class: name) {
            legend(class: 'hide') { text }
          }
        }.to_s
      end
    end
  end
end
