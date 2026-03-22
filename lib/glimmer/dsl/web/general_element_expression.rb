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
          if parent.bulk_render? || parent.rendered? || parent.skip_content_on_render_blocks?
            # TODO somewhere here we must render with html_mutation (e.g. prepend)
            return_value = super(parent, keyword, *args, &block)
            parent.add_text_content(return_value, on_empty: true) if return_value.is_a?(String)
            parent.post_add_content
            return_value
          else
            # TODO pass *args
            parent.add_content_on_render(*args, &block)
          end
        end
      end
    end
  end
end
