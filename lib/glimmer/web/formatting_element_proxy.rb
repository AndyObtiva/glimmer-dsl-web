# backtick_javascript: true

# Copyright (c) 2023-2024 Andy Maleh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
          elsif args.any? && !args.first.is_a?(Hash) && !Glimmer::Web::ElementProxy::HTML_ELEMENT_BOOLEAN_ATTRIBUTES.include?(args.first)
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
          # TODO add boolean_attributes
          ElementProxy.render_html(keyword, attributes: attribute_hash, boolean_attributes:, content:)
        end
      end
      
      FORMATTING_ELEMENT_KEYWORDS = %w[b i strong em sub sup del ins small mark br]
    end
  end
end
