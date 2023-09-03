require 'glimmer/swt/layout_proxy'

module Glimmer
  module SWT
    class FillLayoutProxy < LayoutProxy
      include Glimmer
      
      STYLE = <<~CSS
        .fill-layout {
          display: flex;
        }
        
        .fill-layout > * {
          width: 100% !important;
          height: 100% !important;
        }
        
        .fill-layout-horizontal {
          flex-direction: row;
        }
        
        .fill-layout-vertical {
          flex-direction: column;
        }
      CSS
    
      attr_reader :type, :margin_width, :margin_height, :spacing
    
      def initialize(parent, args)
        super(parent, args)
        self.type = @args.first || :horizontal
        self.margin_width = 15
        self.margin_height = 15
        @parent.css_classes << 'fill-layout'
        @parent.dom_element.add_class('fill-layout')
      end
      
      def horizontal?
        @type == :horizontal
      end

      def vertical?
        @type == :vertical
      end
      
      def type=(value)
        @parent.dom_element.remove_class(horizontal? ? 'fill-layout-horizontal' : 'fill-layout-vertical')
        @parent.css_classes.delete(horizontal? ? 'fill-layout-horizontal' : 'fill-layout-vertical')
        @type = value
        @parent.dom_element.add_class(horizontal? ? 'fill-layout-horizontal' : 'fill-layout-vertical')
        @parent.css_classes << horizontal? ? 'fill-layout-horizontal' : 'fill-layout-vertical'
      end

      def margin_width=(pixels)
        @margin_width = pixels
        # Using padding for width since margin-right isn't getting respected with width 100%
        @parent.dom_element.css('padding-left', @margin_width)
        @parent.dom_element.css('padding-right', @margin_width)
      end
      
      def margin_height=(pixels)
        @margin_height = pixels
        @parent.dom_element.css('padding-top', @margin_height)
        @parent.dom_element.css('padding-bottom', @margin_height)
      end
      
      def spacing=(spacing)
        @spacing = spacing.to_i
        # TODO implement changes to accomodate layout_data in the future
        @parent.style_element.html css {
          s("##{@parent.id} > *") {
            if horizontal?
              margin_right "#{@spacing}px"
            elsif vertical?
              margin_bottom "#{@spacing}px"
            end
          }
          s("##{@parent.id} > :last-child") {
            if horizontal?
              margin_right 0
            elsif vertical?
              margin_bottom 0
            end
          }
        }.to_s
      end
      
    end
  end
end
