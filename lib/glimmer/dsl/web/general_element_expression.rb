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
          options = args.last.is_a?(Hash) ? args.last : {}
          parent.mutation = options[:mutation] || :append
          if parent.bulk_render? || parent.rendered? || parent.skip_content_on_render_blocks?
            # TODO during interpretation of DSL in super, elements are added to parent by default.
            # Could we perhaps set a flag on the parent, to indicate that rendered elements are prepended?
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
