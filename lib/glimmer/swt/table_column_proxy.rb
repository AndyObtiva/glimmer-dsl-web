require 'glimmer/swt/widget_proxy'
require 'glimmer/swt/swt_proxy'

module Glimmer
  module SWT
    class TableColumnProxy < WidgetProxy
      include Glimmer
      
      STYLE = <<~CSS
        th.table-column {
          background: rgb(246, 246, 246);
          text-align: left;
          padding: 5px;
        }
        
        th.table-column .sort-direction {
          float: right;
        }
      CSS
            
      attr_accessor :sort_block, :sort_by_block
      attr_reader :text, :width,
                  :no_sort, :sort_property, :editor
      alias no_sort? no_sort
      
      def initialize(parent, args, block)
        @no_sort = args.delete(:no_sort)
        super(parent, args, block)
        unless no_sort?
          content {
            on_widget_selected { |event|
              parent.sort_by_column!(self)
            }
          }
        end
      end
      
      def sort_property=(args)
        @sort_property = args unless args.empty?
      end
      
      def sort_direction
        parent.sort_direction if parent.sort_column == self
      end
      
      def redraw_sort_direction
        sort_icon_dom_element.attr('class', sort_icon_class)
      end
            
      def text=(value)
        @text = value
        redraw
      end
    
      def width=(value)
        @width = value
        redraw
      end
      
      def parent_path
        parent.columns_path
      end
      
      def element
        'th'
      end
      
      def sort_icon_class
        @sort_icon_class = 'sort-direction'
        @sort_icon_class += (sort_direction == SWTProxy[:up] ? ' ui-icon ui-icon-caret-1-n' : ' ui-icon ui-icon-caret-1-s') unless sort_direction.nil?
        @sort_icon_class
      end
      
      def sort_icon_dom_element
        dom_element.find('.sort-direction')
      end
      
      # Sets editor (e.g. combo)
      def editor=(*args)
        @editor = args
      end
      
      def editable?
        !@editor&.include?(:none)
      end
      
      def observation_request_to_event_mapping
        {
          'on_widget_selected' => {
            event: 'click',
            event_handler: -> (event_listener) {
              -> (event) {
                event_listener.call(event)
                redraw_sort_direction
              }
            }
          },
        }
      end
      
      def dom
        table_column_text = text
        table_column_id = id
        table_column_id_style = "width: #{width}px;"
        table_column_css_classes = css_classes
        table_column_css_classes << name
        @dom ||= html {
          th(id: table_column_id, style: table_column_id_style, class: table_column_css_classes.to_a.join(' ')) {
            span {table_column_text}
            span(class: sort_icon_class)
          }
        }.to_s
      end
    end
  end
end
