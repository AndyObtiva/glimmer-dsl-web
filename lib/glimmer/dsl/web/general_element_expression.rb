require 'glimmer/dsl/parent_expression'
require 'glimmer/web/element_proxy'

module Glimmer
  module DSL
    module Web
      module GeneralElementExpression
        include ParentExpression

        def interpret(parent, keyword, *args, &block)
          # TODO this code is not falling in the root element of a component
          # yet in the first element nested under a consumed component
          # To nest under the former, I need to detect an element as representing a component
          # to automate the work
#           if parent.is_a?(Glimmer::Web::Component)
#             markup_root_slot_option = {slot: :markup_root_slot}
#             if args.last.is_a?(Hash)
#               args.last.merge!(markup_root_slot_option)
#             else
#               args << markup_root_slot_option
#             end
#           end
          Glimmer::Web::ElementProxy.new(keyword, parent, args, block)
        end
        
        def add_content(parent, keyword, *args, &block)
          if parent.bulk_render? || parent.rendered? || parent.skip_content_on_render_blocks?
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
