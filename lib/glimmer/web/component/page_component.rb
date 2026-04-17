module PageComponent
  class << self
    def page_url_to_component_mapping
      unless defined?(@@page_url_to_component_mapping)
        @@page_url_to_component_mapping = {}
      end
      @@page_url_to_component_mapping
    end
    
    def last_visible_page_components
      unless defined?(@@last_visible_page_components)
        @@last_visible_page_components = []
      end
      @@last_visible_page_components
    end
    
    def register_page_component_history_listener
      unless defined?(@@registered_page_component_history_listener)
        @@registered_page_component_history_listener = true
        $$.addEventListener('popstate') do |event|
          page_component = PageComponent.page_url_to_component_mapping[$$.document.location.href]
          if page_component
            visible_page_component = PageComponent.last_visible_page_components.pop
            visible_page_component.markup_root.hide
            page_component.markup_root.show
            PageComponent.last_visible_page_components.push(page_component)
          end
        end
      end
    end
  end
end
