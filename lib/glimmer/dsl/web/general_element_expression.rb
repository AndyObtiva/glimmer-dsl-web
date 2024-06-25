require 'glimmer/dsl/parent_expression'
require 'glimmer/web/element_proxy'

module Glimmer
  module DSL
    module Web
      module GeneralElementExpression
        include ParentExpression

        def interpret(parent, keyword, *args, &block)
          Glimmer::Web::ElementProxy.new(keyword, parent, args, block)
        end
        
        def add_content(parent, keyword, *args, &block)
          if parent.batch_render? || parent.rendered? || parent.skip_content_on_render_blocks?
            return_value = super(parent, keyword, *args, &block)
            parent.add_text_content(return_value, on_empty: true) if return_value.is_a?(String)
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
