require 'glimmer/swt/layout_proxy'

module Glimmer
  module SWT
    class GridLayoutProxy < LayoutProxy
      STYLE = <<~CSS
        .grid-layout {
          display: grid;
          grid-template-rows: min-content;
          place-content: start;
          align-items: stretch;
        }
      CSS
      
      attr_reader :num_columns, :make_columns_equal_width, :horizontal_spacing, :vertical_spacing, :margin_width, :margin_height, :margin_top, :margin_right, :margin_bottom, :margin_left
    
      def num_columns=(columns)
        @num_columns = columns
        @parent.dom_element.css('grid-template-columns', 'auto ' * @num_columns.to_i)
        @parent.dom_element.find('legend').css('grid-column-start', "span #{@num_columns.to_i}") if @parent.is_a?(GroupProxy)
      end
      
      def make_columns_equal_width=(equal_width)
        @make_columns_equal_width = equal_width
        if @make_columns_equal_width
          @parent.dom_element.css('grid-template-columns', "#{100.0/@num_columns.to_f}% " * @num_columns.to_i)
        else
          @parent.dom_element.css('grid-template-columns', 'auto ' * @num_columns.to_i)
        end
      end
      
      def horizontal_spacing=(spacing)
        @horizontal_spacing = spacing
        @parent.dom_element.css('grid-column-gap', "#{@horizontal_spacing}px")
      end

      def vertical_spacing=(spacing)
        @vertical_spacing = spacing
        @parent.dom_element.css('grid-row-gap', "#{@vertical_spacing}px")
      end
      
      def margin_width=(pixels)
        @margin_width = pixels
        # Using padding for width since margin-right isn't getting respected with width 100%
        effective_margin_width = @margin_width
        effective_margin_width += 6 if @parent.is_a?(GroupProxy)
        @parent.dom_element.css('padding-left', effective_margin_width)
        @parent.dom_element.css('padding-right', effective_margin_width)
      end
      
      def margin_height=(pixels)
        @margin_height = pixels
        effective_margin_height = @margin_height
        effective_margin_height += 9 if @parent.is_a?(GroupProxy)
        @parent.dom_element.css('padding-top', effective_margin_height)
        @parent.dom_element.css('padding-bottom', effective_margin_height)
      end
      
      def margin_top=(pixels)
        @margin_top = pixels
        # Using padding for width since margin-right isn't getting respected with width 100%
        effective_margin_top = @margin_top
        effective_margin_top += 9 if @parent.is_a?(GroupProxy)
        @parent.dom_element.css('padding-top', effective_margin_top)
      end
      
      def margin_right=(pixels)
        @margin_right = pixels
        effective_margin_right = @margin_right
        effective_margin_right += 6 if @parent.is_a?(GroupProxy)
        @parent.dom_element.css('padding-right', effective_margin_right)
      end
      
      def margin_bottom=(pixels)
        @margin_bottom = pixels
        # Using padding for width since margin-right isn't getting respected with width 100%
        effective_margin_bottom = @margin_bottom
        effective_margin_bottom += 9 if @parent.is_a?(GroupProxy)
        @parent.dom_element.css('padding-bottom', effective_margin_bottom)
      end
      
      def margin_left=(pixels)
        @margin_left = pixels
        effective_margin_left = @margin_left
        effective_margin_left += 6 if @parent.is_a?(GroupProxy)
        @parent.dom_element.css('padding-left', effective_margin_left)
      end
            
      
            
      def initialize(parent, args)
        super(parent, args)
        self.horizontal_spacing = 10
        self.vertical_spacing = 10
        self.margin_width = 15
        self.margin_height = 15
        self.num_columns = @args[0] || 1
        self.make_columns_equal_width = @args[1] || false
      end
    end
  end
end
