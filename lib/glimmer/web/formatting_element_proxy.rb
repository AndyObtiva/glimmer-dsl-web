# backtick_javascript: true

require 'glimmer/web/element_proxy'

module Glimmer
  module Web
    class FormattingElementProxy
      class << self
        include Glimmer
        
        def keyword_supported?(keyword, parent: nil)
          # TODO do we need to worry about the parent of the parent being a p tag?
          keyword = keyword.to_s
          parent_keyword = parent.is_a?(Component) ? parent.markup_root&.keyword : parent&.keyword
          
          parent_keyword == 'p' &&
            (
              FORMATTING_ELEMENT_KEYWORDS.include?(keyword) ||
              (keyword == 'span') ||
              (keyword == 'a')
            )
        end
      
        def format(keyword, *args, &block)
          content = nil
          boolean_attributes = []
          if block_given?
            content = block.call.to_s
          elsif args.any? && !args.first.is_a?(Hash) && !Glimmer::Web::ElementProxy.element_boolean_attribute?(keyword, args.first)
            content = args.first.to_s
            args = args[1, args.size - 1]
          end
          if args.last.is_a?(Hash)
            attribute_hash = args.last
            boolean_attributes = args[0, args.size - 1]
          else
            attribute_hash = {}
            boolean_attributes = args
          end
          ElementProxy.render_html(keyword, attributes: attribute_hash, boolean_attributes:, content:)
        end
      end
      
      FORMATTING_ELEMENT_KEYWORDS = %w[b i strong em sub sup del ins small mark br]
    end
  end
end
