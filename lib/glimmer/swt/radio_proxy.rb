require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    class RadioProxy < WidgetProxy
      # TODO add a create method that ensures passing :radio style in if not there
      STYLE = <<~CSS
        .radio {
          display: inline;
        }
        .radio-label {
          display: inline;
        }
        .radio-container {
        }
      CSS
      
      def text
        label_dom_element.html
      end
      
      def text=(value)
        label_dom_element.html(value)
      end
      
      def selection
        dom_element.prop('checked')
      end
      
      def selection=(value)
        dom_element.prop('checked', value)
      end
      
      def element
        'input'
      end
      
      def label_id
        "#{id}-label"
      end
      
      def label_name
        "#{name}-label"
      end
      
      def label_path
        "#{parent_path} ##{label_id}"
      end
      
      def label_dom_element
        Document.find(label_path)
      end
      
      def container_id
        "#{id}-container"
      end

      def container_name
        "#{name}-container"
      end

      def observation_request_to_event_mapping
        {
          'on_widget_selected' => {
            event: 'change'
          },
        }
      end
      
      def dom
        @dom ||= html {
          span(id: container_id, class: container_name) {
            input(type: 'radio', id: id, class: name, name: parent&.id)
            label(id: label_id, class: label_name, for: id) {
              text
            }
          }
        }.to_s
      end
    end
  end
end
