require 'glimmer/dsl/expression'
require 'glimmer/dsl/web/general_element_expression'

module Glimmer
  module DSL
    module Web
      class StyleExpression < Expression
        include GeneralElementExpression
        include Glimmer
        
        def can_interpret?(parent, keyword, *args, &block)
          keyword == 'style' &&
            !block.nil?
        end
        
        def add_content(parent, keyword, *args, &block)
          if parent.bulk_render? || parent.rendered? || parent.skip_content_on_render_blocks?
            return_value = css(&block).to_s
            return_value = super(parent, keyword, *args, &block) if return_value.to_s.empty?
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
