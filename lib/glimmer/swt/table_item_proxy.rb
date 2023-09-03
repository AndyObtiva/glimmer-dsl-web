# Copyright (c) 2020-2022 Andy Maleh
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

require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    class TableItemProxy < WidgetProxy
      STYLE = <<~CSS
        tr.table-item td {
          padding-bottom: 0;
        }
        tr.table-item:nth-child(odd):not(.selected) {
          background: white;
        }
        tr.table-item:nth-child(even):not(.selected) {
          background: rgb(243, 244, 246);
        }
      CSS
      
      attr_reader :data
      
      def initialize(parent, args, block)
        super(parent, args, block)
        # TODO check if there is a need to remove this observer when removing widget from table upon items update
        on_widget_selected do |event|
          parent.select(parent.index_of(self), (event.meta? if event.respond_to?(:meta?)))
        end
      end
      
      def get_text(index)
        text_array[index]
      end
      
      def set_text(index, text_value)
        text_array[index] = text_value
        redraw
      end
      
      def text_array
        @text_array ||= []
      end

      def parent_path
        parent.items_path
      end
      
      def element
        'tr'
      end
      
      def cell_dom_element(column_index)
        dom_element.find("td:nth-child(#{column_index + 1})")
      end
      
      def redraw
        super() #TODO re-enable and remove below lines

        # TODO perhaps turn the following lambdas into methods
        table_item_edit_handler = lambda do |event, cancel = false|
          Async::Task.new do
            text_value = event.target.value
            edit_property = parent.column_properties[@edit_column_index]
            edit_model = get_data
            if !cancel && edit_model.send(edit_property) != text_value
              edit_model.send("#{edit_property}=", text_value)
              set_text(@edit_column_index, text_value)
            end
            @edit_column_index = nil
            redraw
          end
        end
        table_item_edit_cancel_handler = lambda do |event|
          Async::Task.new do
            table_item_edit_handler.call(event, true)
          end
        end
        table_item_edit_key_handler = lambda do |event|
          Async::Task.new do
            if event.key_code == 13
              table_item_edit_handler.call(event)
            elsif event.key_code == 27
              table_item_edit_cancel_handler.call(event)
            end
          end
        end
        
        if @edit_column_index
          table_item_input = dom_element.find("td:nth-child(#{@edit_column_index + 1}) input")
          if !table_item_input.empty?
            Async::Task.new do
              table_item_input.focus
              table_item_input.on('keyup', &table_item_edit_key_handler)
              table_item_input.on('focusout', &table_item_edit_cancel_handler)
            end
          end
        end
      end
      
      def edit(column_index)
        return if @edit_column_index == column_index.to_i
        parent.select(parent.index_of(self), false)
        @edit_column_index = column_index.to_i
        redraw
      end
      
      def redraw_selection
        if parent.selection.include?(self)
          dom_element.add_class('selected')
        else
          dom_element.remove_class('selected')
        end
      end
      
      def observation_request_to_event_mapping
        {
          'on_widget_selected' => {
            event: 'mouseup',
          }
        }
      end
      
      def max_column_width(column_index)
        parent_dom_element.find("tr td:nth-child(#{column_index + 1})").first.width
      end
      
      def dom
        table_item_id = id
        table_item_id_style = css
        table_item_css_classes = css_classes
        table_item_css_classes << name
        table_item_selection = parent.selection.include?(self)
        if table_item_selection
          table_item_css_classes << 'selected'
        else
          table_item_css_classes.delete('selected')
        end
        table_item_text_array = text_array
        table_item_max_width = max_column_width(@edit_column_index) if @edit_column_index

        @dom ||= html {
          tr(id: table_item_id, style: table_item_id_style, class: table_item_css_classes.to_a.join(' ')) {
            table_item_text_array.each_with_index do |table_item_text, column_index|
              td('data-column-index' => column_index) {
                if @edit_column_index == column_index
                  input(type: 'text', value: table_item_text, style: "max-width: #{table_item_max_width - 11}px;")
                else
                  table_item_text
                end
              }
            end
          }
        }.to_s
      end
    end
  end
end
