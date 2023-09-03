require 'glimmer/swt/layout_proxy'

module Glimmer
  module SWT
    class RowLayoutProxy < LayoutProxy
      include Glimmer
      
      STYLE = <<~CSS
        .row-layout {
          display: flex;
          align-items: flex-start;
        }
                
        .row-layout-pack-false {
          align-items: stretch;
        }
        
        .row-layout-center.row-layout-horizontal > * {
          margin-top: auto;
          margin-bottom: auto;
        }
                
        .row-layout-center.row-layout-vertical > * {
          margin-left: auto;
          margin-right: auto;
        }
        
        .row-layout-wrap {
          flex-wrap: wrap;
        }
                
        .row-layout-justify {
          justify-content: space-around;
        }
                
        .row-layout-horizontal {
          flex-direction: row;
        }
        
        .row-layout-horizontal.row-layout-pack-false {
          flex-direction: unset;
        }
        
        .row-layout-vertical {
          flex-direction: column;
        }
        
        .row-layout-vertical.row-layout-pack {
          flex-direction: none;
        }
      CSS
    
      attr_reader :type, :margin_width, :margin_height, :margin_top, :margin_right, :margin_bottom, :margin_left, :spacing, :pack, :center, :wrap, :justify
        
      def initialize(parent, args)
        super(parent, args)
        @parent.dom_element.add_class('row-layout')
        self.type = args.first || :horizontal
        self.pack = true
        self.wrap = true
      end
      
      def type=(value)
        @type = value
        @parent.dom_element.add_class(horizontal? ? 'row-layout-horizontal' : 'row-layout-vertical')
      end
      
      def horizontal?
        @type == :horizontal
      end

      def vertical?
        @type == :vertical
      end
      
      def dom(widget_dom)
        dom_result = widget_dom
        dom_result += '<br />' if vertical? && @pack
        dom_result
      end

      def pack=(value)
        @pack = value
        if @pack
          @parent.dom_element.remove_class('row-layout-pack-false')
        else
          @parent.dom_element.add_class('row-layout-pack-false')
        end
      end
      
      def fill
        !pack
      end
      
      def fill=(value)
        # TODO verify this is a correct implementation and interpretation of RowLayout in SWT
        self.pack = !value
      end
      
      def center=(center_value)
        @center = center_value
        # Using padding for width since margin-right isn't getting respected with width 100%
        if @center
          parent.dom_element.add_class("row-layout-center")
        else
          parent.dom_element.remove_class("row-layout-center")
        end
      end
      
      def wrap=(wrap_value)
        @wrap = wrap_value
        if @wrap
          parent.dom_element.add_class("row-layout-wrap")
        else
          parent.dom_element.remove_class("row-layout-wrap")
        end
      end
      
      def justify=(justify_value)
        @justify = justify_value
        if @justify
          parent.dom_element.add_class("row-layout-justify")
        else
          parent.dom_element.remove_class("row-layout-justify")
        end
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
      
      def margin_top=(pixels)
        @margin_top = pixels
        # Using padding for width since margin-right isn't getting respected with width 100%
        @parent.dom_element.css('padding-top', @margin_top)
      end
      
      def margin_right=(pixels)
        @margin_right = pixels
        @parent.dom_element.css('padding-right', @margin_right)
      end
      
      def margin_bottom=(pixels)
        @margin_bottom = pixels
        # Using padding for width since margin-right isn't getting respected with width 100%
        @parent.dom_element.css('padding-bottom', @margin_bottom)
      end
      
      def margin_left=(pixels)
        @margin_left = pixels
        @parent.dom_element.css('padding-left', @margin_left)
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
