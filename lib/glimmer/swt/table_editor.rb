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

require 'glimmer/swt/control_editor'

module Glimmer
  module SWT
    # Emulates SWT's native org.eclipse.swt.custom.TableEditor
    class TableEditor < ControlEditor
      alias table composite
      
      def editor=(editor_widget, table_item, table_column_index)
        # TODO consider making editor not gain an ID or gain a separate set of IDs to avoid clashing with standard widget predictability of ID
        @table_item = table_item
        @table_column_index = table_column_index
        @editor_widget = editor_widget
        @old_value = table_item.cell_dom_element(table_column_index).html
        table_item.cell_dom_element(table_column_index).html('')
        editor_widget.render(custom_parent_dom_element: table_item.cell_dom_element(table_column_index))
        # TODO tweak the width perfectly so it doesn't expand the table cell
#         editor_widget.dom_element.css('width', 'calc(100% - 20px)')
        editor_widget.dom_element.css('width', "#{minimumWidth}%") # TODO implement property with pixels (and perhaps derive percentage separately from pixels)
        editor_widget.dom_element.css('height', "#{minimumHeight}px")
        editor_widget.dom_element.add_class('table-editor')
        # TODO consider relying on autofocus instead
        editor_widget.dom_element.focus
        # TODO consider doing the following line only for :text editor
        editor_widget.dom_element.select
      end
      alias set_editor editor=
      alias setEditor editor=
      
      def cancel!
        done!
      end
      
      def save!
        done!
      end
      
      def done!
        @table_item.cell_dom_element(@table_column_index).html(@old_value) unless @old_value.nil?
        @old_value = nil
      end
    end
  end
end
