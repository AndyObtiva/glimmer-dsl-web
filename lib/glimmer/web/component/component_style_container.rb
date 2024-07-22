require 'glimmer/web/component'

class ComponentStyleContainer
  include Glimmer::Web::Component
  
  option :component
  
  markup {
    component_style_container_block = component.class.instance_variable_get("@style_block")
    component_style_container_class = "#{component.class.component_element_class}-style"
    style(class: component_style_container_class, &component_style_container_block)
  }
end
