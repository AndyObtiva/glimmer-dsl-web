# Superclass for NewTodoInput and EditTodoInput with common styles
class TodoInput
  include Glimmer::Web::Component
  
  class << self
    def todo_input_styles
      rule(".#{component_element_class}") {
        position 'relative'
        margin '0'
        width '100%'
        font_size '24px'
        font_family 'inherit'
        font_weight 'inherit'
        line_height '1.4em'
        color 'inherit'
        padding '6px'
        border '1px solid #999'
        box_shadow 'inset 0 -1px 5px 0 rgba(0, 0, 0, 0.2)'
        box_sizing 'border-box'
        _webkit_font_smoothing 'antialiased'
      }
      
      rule(".#{component_element_class}::selection") {
        background 'red'
      }
      
      rule(".#{component_element_class}:focus") {
        box_shadow '0 0 2px 2px #cf7d7d'
        outline '0'
      }
    end
  end
end
