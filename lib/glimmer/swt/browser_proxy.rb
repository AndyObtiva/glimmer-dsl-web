require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    class BrowserProxy < WidgetProxy
      attr_reader :url
      
      def url=(value)
        @url = value
        dom_element.attr('src', @url)
      end
    
      def element
        'iframe'
      end
    
      def dom
        iframe_id = id
        iframe_url = url
        @dom ||= html {
          iframe(id: iframe_id, class: name, src: iframe_url, frameBorder: 0) {
          }
        }.to_s
      end      
    end
  end
end
