require 'glimmer/dsl/parent_expression'
require 'glimmer/web/element_proxy'

module Glimmer
  module DSL
    module Web
      module GeneralElementExpression
        include ParentExpression

        def interpret(parent, keyword, *args, &block)
          Glimmer::Web::ElementProxy.for(keyword, parent, args, block)
        end
        
        def add_content(parent, keyword, *args, &block)
          if parent.rendered? || parent.skip_content_on_render_blocks?
            return_value = super(parent, keyword, *args, &block)
            if return_value.is_a?(String) && parent.dom_element.text.to_s.empty?
              parent.add_text_content(return_value)
            end
            parent.post_add_content
            return_value
          else
            parent.add_content_on_render(&block)
          end
        end
      end
    end
  end
end
