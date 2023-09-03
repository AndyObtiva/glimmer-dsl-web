require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    class CheckboxProxy < WidgetProxy
      # TODO add a create method that ensures passing :check style in if not there
      STYLE=<<~CSS
        .checkbox {
          display: inline;
        }
        .checkbox-label {
          display: inline;
        }
      CSS
      # TODO consider reuse of logic in Radioproxy
      attr_reader :text
      
      def text=(value)
        @text = value
        dom_element.val(@text)
        label_dom_element.html(@text)
      end

      def selection
        dom_element.prop('checked')
      end
      
      def selection=(value)
        @selection = value
        dom_element.prop('checked', @selection)
      end
      
      def element
        'input'
      end

      def observation_request_to_event_mapping
        {
          'on_widget_selected' => {
            event: 'change'
          },
        }
      end
      
      def label_id
        "#{id}-label"
      end
      
      def label_class
        "#{name}-label"
      end
      
      def label_dom_element
        Element.find("##{label_id}")
      end
      
      def dom
        check_text = @text
        check_id = id
        check_style = "min-width: 27px; #{css}"
        check_class = name
        check_selection = @selection
        # TODO `:style` key is duplicated twice
        options = {type: 'checkbox', id: check_id, name: parent.id, style: check_style, class: check_class, value: check_text}
        options[checked: 'checked'] if check_selection
        @dom ||= html {
          span {
            input(options) {
            }
            label(id: label_id, class: label_class, for: check_id) {
              check_text
            }
          }
        }.to_s
      end
      
    end
    
    CheckProxy = CheckboxProxy # alias
  end
  
end
