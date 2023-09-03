require 'glimmer/dsl/expression'
require 'glimmer/dsl/parent_expression'
require 'glimmer/swt/widget_proxy'

module Glimmer
  module DSL
    module Opal
      class WidgetExpression < Expression
        include ParentExpression
        
        EXCLUDED_KEYWORDS = %w[shell display]
  
        def can_interpret?(parent, keyword, *args, &block)
          !EXCLUDED_KEYWORDS.include?(keyword) and
            parent.is_a?(Glimmer::SWT::WidgetProxy) and
            Glimmer::SWT::WidgetProxy.widget_class(keyword)
        end

        def interpret(parent, keyword, *args, &block)
          Glimmer::SWT::WidgetProxy.for(keyword, parent, args, block)
        end
        
        def add_content(parent, keyword, *args, &block)
          if parent.rendered? || parent.skip_content_on_render_blocks?
            super(parent, keyword, *args, &block)
            parent.post_add_content
          else
            parent.add_content_on_render(&block)
          end
        end
      end
    end
  end
end
