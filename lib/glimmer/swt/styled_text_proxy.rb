require 'glimmer/swt/widget_proxy'
require 'glimmer/swt/text_proxy'
require 'glimmer/swt/swt_proxy'

module Glimmer
  module SWT
    class StyledTextProxy < TextProxy
      attr_reader :alignment, :right_margin, :editable, :caret
      
      def alignment=(value)
        @alignment = %w[left center right].detect {|alignment_value| SWTProxy[alignment_value] == value}
        dom_element.css('text-align', @alignment)
      end
      
      def right_margin=(value)
        @right_margin = value.to_i
        dom_element.css('padding-right', @right_margin)
      end
      
      def editable=(value)
        @editable = value
        if !@editable
          dom_element.attr('disabled', true)
          dom_element.css('background', :white)
          dom_element.css('border', 'solid 1px rgb(118, 118, 118)')
          dom_element.css('border-radius', '3px')
          # :hover {
          #     border-color: rgb(80, 80, 80);
          # }        
        else
          dom_element.prop('disabled', false)
          dom_element.css('background', nil)
          dom_element.css('border', nil)
          dom_element.css('border-radius', nil)
        end
      end
      
      def caret=(value)
        @caret = value
        # TODO implement (not needed for disabling caret though)
      end
    end
  end
end
