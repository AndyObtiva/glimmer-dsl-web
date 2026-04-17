require 'glimmer/web/component/page_component'

class PageComponentLink
  include Glimmer::Web::Component
  
  attributes :text, :component_class, :component_attributes, :page_url, :css_id, :css_class, :css_style
  attr_reader :original_page_component
  
  before_render do
    if self.page_url.start_with?('/')
      self.page_url = "#{$$.document.location.origin}#{self.page_url}"
    end
    @anchor_tag_attributes = {href: page_url}
    @anchor_tag_attributes[:id] = css_id if css_id
    @anchor_tag_attributes[:class] = css_class if css_class
    @anchor_tag_attributes[:style] = css_style if css_style
  end
  
  after_render do
    @original_page_component = root_component
  end
  
  markup {
    a(text, **@anchor_tag_attributes) {
      onclick do |event|
        event.prevent_default
        page_component = nil
        if component_attributes.nil?
          page_component = PageComponent.page_url_to_component_mapping[page_url]
          if page_component
            page_component.markup_root.show
          else
            $$.document.location = page_url
          end
        else
          page_component = component_class.render(component_attributes)
        end
        if page_component
          PageComponent.last_visible_page_components.push(page_component)
          PageComponent.page_url_to_component_mapping[$$.document.location.href] = original_page_component
          PageComponent.page_url_to_component_mapping[page_url] = page_component
          $$.history.pushState({page_component_selector: page_component.markup_root.selector, original_page_component_selector: original_page_component.markup_root.selector}, "title 1", page_url)
          original_page_component.markup_root.hide
          PageComponent.register_page_component_history_listener
        end
      end
    }
  }
end
