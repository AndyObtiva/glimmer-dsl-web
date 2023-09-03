
require 'glimmer/data_binding/observable_element'
require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    class ComboProxy < WidgetProxy
      include Glimmer::DataBinding::ObservableElement
      attr_reader :text, :items
      
      def initialize(parent, args, block)
        super(parent, args, block)
        @items = []
      end
      
      def element
        'select'
      end
      
      def text=(value)
        @text = value
        dom_element.val(value)
      end
      
      def selection
        text
      end
      
      def selection=(value)
        self.text = value
      end
      
      def items=(the_items)
        @items = the_items
        items_dom = items.to_a.map do |item|
          option_hash = {value: item}
          option_hash[:selected] = 'selected' if @text == item
          html {
            option(option_hash) {
              item
            }
          }.to_s
        end
        dom_element.html(items_dom)
      end

      def observation_request_to_event_mapping
        {
          'on_widget_selected' => {
            event: 'change',
            event_handler: -> (event_listener) {
              -> (event) {
                @text = event.target.value
                event_listener.call(event)
              }
            }
          },
        }
      end
      
      def dom
        items = @items
        select_id = id
        select_style = css
        select_class = name
        @dom ||= html {
          select(id: select_id, class: select_class, style: select_style) {
          }
        }.to_s
      end
      
    end
    
  end
  
end
