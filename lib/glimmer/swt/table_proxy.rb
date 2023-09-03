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
require 'glimmer/swt/table_column_proxy'
require 'glimmer/swt/table_item_proxy'
require 'glimmer/swt/table_editor'

module Glimmer
  module SWT
    class TableProxy < CompositeProxy
      STYLE = <<~CSS
        table {
          border-spacing: 0;
        }
          
        table tr th,td {
          cursor: default;
        }
      CSS

      attr_reader :columns, :selection,
                  :sort_type, :sort_column, :sort_property, :sort_block, :sort_by_block, :additional_sort_properties,
                  :editor, :table_editor
      attr_accessor :column_properties, :item_count, :data
      alias items children
      alias model_binding data
      
      class << self
        include Glimmer
        
        def editors
          @editors ||= {
            # ensure editor can work with string keys not just symbols (leave one string in for testing)
            text: {
              widget_value_property: :text,
              editor_gui: lambda do |args, model, property, table_proxy|
                table_proxy.table_editor.minimumWidth = 90
                table_proxy.table_editor.minimumHeight = 10
                table_editor_widget_proxy = text(*args) {
                  text model.send(property)
                  focus true
                  on_focus_lost {
                    table_proxy.finish_edit!
                  }
                  on_modify_text do |event|
                    # No Op, just record @text changes on key up
                    # TODO find a better solution than this in the future
                  end
                  on_key_pressed { |key_event|
                    if key_event.keyCode == swt(:cr)
                      table_proxy.finish_edit!
                    elsif key_event.keyCode == swt(:esc)
                      table_proxy.cancel_edit!
                    end
                  }
                }
#                 table_editor_widget_proxy.swt_widget.selectAll # TODO select all
                table_editor_widget_proxy
              end,
            },
            combo: {
              widget_value_property: :text,
              editor_gui: lambda do |args, model, property, table_proxy|
                first_time = true
                table_proxy.table_editor.minimumWidth = 90
                table_proxy.table_editor.minimumHeight = 18
                table_editor_widget_proxy = combo(*args) {
                  items model.send("#{property}_options")
                  text model.send(property)
                  focus true
                  on_focus_lost {
                    table_proxy.finish_edit!
                  }
                  on_key_pressed { |key_event|
                    if key_event.keyCode == swt(:cr)
                      table_proxy.finish_edit!
                    elsif key_event.keyCode == swt(:esc)
                      table_proxy.cancel_edit!
                    end
                  }
                  on_widget_selected {
                    if !OS.windows? || !first_time || first_time && model.send(property) != table_editor_widget_proxy.text
                      table_proxy.finish_edit!
                    end
                  }
                }
                table_editor_widget_proxy
              end,
            },
            checkbox: {
              widget_value_property: :selection,
              editor_gui: lambda do |args, model, property, table_proxy|
                first_time = true
                table_proxy.table_editor.minimumHeight = 25
                checkbox(*args) {
                  selection model.send(property)
                  focus true
                  on_widget_selected {
                    table_proxy.finish_edit!
                  }
                  on_focus_lost {
                    table_proxy.finish_edit!
                  }
                  on_key_pressed { |key_event|
                    if key_event.keyCode == swt(:cr)
                      table_proxy.finish_edit!
                    elsif key_event.keyCode == swt(:esc)
                      table_proxy.cancel_edit!
                    end
                  }
                }
              end,
            },
            date: {
              widget_value_property: :date_time,
              editor_gui: lambda do |args, model, property, table_proxy|
                first_time = true
                table_proxy.table_editor.minimumWidth = 90
                table_proxy.table_editor.minimumHeight = 15
                date(*args) {
                  date_time model.send(property)
                  focus true
                  on_widget_selected {
                    table_proxy.finish_edit!
                  }
                  on_key_pressed { |key_event|
                    if key_event.keyCode == swt(:cr)
                      table_proxy.finish_edit!
                    elsif key_event.keyCode == swt(:esc)
                      table_proxy.cancel_edit!
                    end
                  }
                }
              end,
            },
            date_drop_down: {
              widget_value_property: :date_time,
              editor_gui: lambda do |args, model, property, table_proxy|
                first_time = true
                table_proxy.table_editor.minimumWidth = 80
                table_proxy.table_editor.minimumHeight = 15
                date_drop_down(*args) {
                  date_time model.send(property)
                  focus true
                  on_widget_selected {
                    table_proxy.finish_edit!
                  }
                  on_key_pressed { |key_event|
                    if key_event.keyCode == swt(:cr)
                      table_proxy.finish_edit!
                    elsif key_event.keyCode == swt(:esc)
                      table_proxy.cancel_edit!
                    end
                  }
                }
              end,
            },
            time: {
              widget_value_property: :date_time,
              editor_gui: lambda do |args, model, property, table_proxy|
                first_time = true
                table_proxy.table_editor.minimumWidth = 80
                table_proxy.table_editor.minimumHeight = 15
                time(*args) {
                  date_time model.send(property)
                  focus true
                  on_widget_selected {
                    table_proxy.finish_edit!
                  }
                  on_focus_lost {
                    table_proxy.finish_edit!
                  }
                  on_key_pressed { |key_event|
                    if key_event.keyCode == swt(:cr)
                      table_proxy.finish_edit!
                    elsif key_event.keyCode == swt(:esc)
                      table_proxy.cancel_edit!
                    end
                  }
                }
              end,
            },
            radio: {
              widget_value_property: :selection,
              editor_gui: lambda do |args, model, property, table_proxy|
                first_time = true
                table_proxy.table_editor.minimumHeight = 25
                radio(*args) {
                  selection model.send(property)
                  focus true
                  on_widget_selected {
                    table_proxy.finish_edit!
                  }
                  on_focus_lost {
                    table_proxy.finish_edit!
                  }
                  on_key_pressed { |key_event|
                    if key_event.keyCode == swt(:cr)
                      table_proxy.finish_edit!
                    elsif key_event.keyCode == swt(:esc)
                      table_proxy.cancel_edit!
                    end
                  }
                }
              end,
            },
            spinner: {
              widget_value_property: :selection,
              editor_gui: lambda do |args, model, property, table_proxy|
                first_time = true
                table_proxy.table_editor.minimumHeight = 25
                table_editor_widget_proxy = spinner(*args) {
                  selection model.send(property)
                  focus true
                  on_focus_lost {
                    table_proxy.finish_edit!
                  }
                  on_key_pressed { |key_event|
                    if key_event.keyCode == swt(:cr)
                      table_proxy.finish_edit!
                    elsif key_event.keyCode == swt(:esc)
                      table_proxy.cancel_edit!
                    end
                  }
                }
                table_editor_widget_proxy
              end,
            },
          }
        end
      end
      
      def initialize(parent, args, block)
        super(parent, args, block)
        @columns = []
        @children = []
        @editors = []
        @selection = []
        @table_editor = TableEditor.new(self)
        @table_editor.horizontalAlignment = SWTProxy[:left]
        @table_editor.grabHorizontal = true
        @table_editor.minimumWidth = 90
        @table_editor.minimumHeight = 20
        if editable?
          add_editable_event_listener
        end
      end
      
      # Only table_columns may be added as children
      def post_initialize_child(child)
        if child.is_a?(TableColumnProxy)
          @columns << child
          child.render
        elsif child.is_a?(TableItemProxy)
          @children << child
          child.render
        else
          @editors << child
        end
      end
      
      # Executes for the parent of a child that just got disposed
      def post_dispose_child(child)
        if child.is_a?(TableColumnProxy)
          @columns&.delete(child)
        elsif child.is_a?(TableItemProxy)
          @children&.delete(child)
        else
          @editors&.delete(child)
        end
      end
      
      def post_add_content
        return if @initially_sorted
        initial_sort!
        @initially_sorted = true
      end
      
      def default_layout
        nil
      end
      
      def get_data(key=nil)
        data
      end
      
      def remove_all
        items.clear
        redraw
      end
      
      def editable?
        args.include?(:editable)
      end
      alias editable editable?
      
      def editable=(value)
        if value
          args.push(:editable)
          dom_element.addClass('editable')
          add_editable_event_listener
        else
          args.delete(:editable)
          dom_element.removeClass('editable')
          @editable_on_mouse_up_event_listener.deregister # TODO see why table event listener deregistration is not working
        end
      end
      
      def add_editable_event_listener
        @editable_on_mouse_up_event_listener = on_mouse_up { |event|
          edit_table_item(event.table_item, event.column_index) if editable?
        }
      end
      
      def selection
        @selection.to_a
      end
      
      def selection=(new_selection)
        new_selection = new_selection.to_a
        changed = (selection + new_selection) - (selection & new_selection)
        @selection = new_selection
        changed.each(&:redraw_selection)
      end
            
      def items=(new_items)
        @children = new_items
        # TODO optimize in the future by sorting elements in DOM directly when no change to elements occur other than sort
        redraw
      end
      
      def item_count=(value)
        @item_count = value
        redraw_empty_items
      end
      
      def cells_for(model)
        column_properties.map {|property| model.send(property)}
      end
      
      def search(&condition)
        items.select {|item| condition.nil? || condition.call(item)}
      end
      
      def index_of(item)
        items.index(item)
      end
      
      def select(index, meta = false)
        new_selection = @selection.clone
        selected_item = items[index]
        if @selection.include?(selected_item)
          new_selection.delete(selected_item) if meta
        else
          new_selection = [] if !meta || (!has_style?(:multi) && @selection.to_a.size >= 1)
          new_selection << selected_item
        end
        self.selection = new_selection
      end
      
      def sort_block=(comparator)
        @sort_block = comparator
      end
      
      def sort_by_block=(property_picker)
        @sort_by_block = property_picker
      end
      
      def sort_property=(new_sort_property)
        @sort_property = new_sort_property.to_collection
      end
      
      def detect_sort_type
        @sort_type = sort_property.size.times.map { String }
        array = model_binding.evaluate_property
        sort_property.each_with_index do |a_sort_property, i|
          values = array.map { |object| object.send(a_sort_property) }
          value_classes = values.map(&:class).uniq
          if value_classes.size == 1
            @sort_type[i] = value_classes.first
          elsif value_classes.include?(Integer)
            @sort_type[i] = Integer
          elsif value_classes.include?(Float)
            @sort_type[i] = Float
          end
        end
      end
      
      def column_sort_properties
        column_properties.zip(columns.map(&:sort_property)).map do |pair|
          pair.compact.last.to_collection
        end
      end
      
      def sort_direction
        @sort_direction == :ascending ? SWTProxy[:up] : SWTProxy[:down]
      end
      
      def sort_direction=(value)
        @sort_direction = value == SWTProxy[:up] ? :ascending : :descending
      end
      
      # Sorts by specified TableColumnProxy object. If nil, it uses the table default sort instead.
      def sort_by_column!(table_column_proxy=nil)
        index = columns.to_a.index(table_column_proxy) unless table_column_proxy.nil?
        new_sort_property = table_column_proxy.nil? ? @sort_property : table_column_proxy.sort_property || [column_properties[index]]
        
        return if table_column_proxy.nil? && new_sort_property.nil? && @sort_block.nil? && @sort_by_block.nil?
        if new_sort_property && table_column_proxy.nil? && new_sort_property.size == 1 && (index = column_sort_properties.index(new_sort_property))
          table_column_proxy = columns[index]
        end
        if new_sort_property && new_sort_property.size == 1 && !additional_sort_properties.to_a.empty?
          selected_additional_sort_properties = additional_sort_properties.clone
          if selected_additional_sort_properties.include?(new_sort_property.first)
            selected_additional_sort_properties.delete(new_sort_property.first)
            new_sort_property += selected_additional_sort_properties
          else
            new_sort_property += additional_sort_properties
          end
        end
        
        new_sort_property = new_sort_property.to_collection unless new_sort_property.is_a?(Array)
        @sort_direction = @sort_direction.nil? || @sort_property.first != new_sort_property.first || @sort_direction == :descending ? :ascending : :descending
        
        @sort_property = new_sort_property
        table_column_index = column_properties.index(new_sort_property.to_s.to_sym)
        table_column_proxy ||= columns[table_column_index] if table_column_index
        @sort_column = table_column_proxy if table_column_proxy
                
        if table_column_proxy
          @sort_by_block = nil
          @sort_block = nil
        end
        @sort_type = nil
        if table_column_proxy&.sort_by_block
          @sort_by_block = table_column_proxy.sort_by_block
        elsif table_column_proxy&.sort_block
          @sort_block = table_column_proxy.sort_block
        else
          detect_sort_type
        end
                
        sort!
      end
      
      def initial_sort!
        sort_by_column!
      end
      
      def sort!
        return unless sort_property && (sort_type || sort_block || sort_by_block)
        array = model_binding.evaluate_property
        array = array.sort_by(&:hash) # this ensures consistent subsequent sorting in case there are equivalent sorts to avoid an infinite loop
        # Converting value to_s first to handle nil cases. Should work with numeric, boolean, and date fields
        if sort_block
          sorted_array = array.sort(&sort_block)
        elsif sort_by_block
          sorted_array = array.sort_by(&sort_by_block)
        else
          sorted_array = array.sort_by do |object|
            sort_property.each_with_index.map do |a_sort_property, i|
              value = object.send(a_sort_property)
              # handle nil and difficult to compare types gracefully
              if sort_type[i] == Integer
                value = value.to_i
              elsif sort_type[i] == Float
                value = value.to_f
              elsif sort_type[i] == String
                value = value.to_s
              end
              value
            end
          end
        end
        sorted_array = sorted_array.reverse if @sort_direction == :descending
        model_binding.call(sorted_array)
      end
      
      def additional_sort_properties=(*args)
        @additional_sort_properties = args unless args.empty?
      end
      
      def editor=(args)
        @editor = args
      end
      
      # Indicates if table is in edit mode, thus displaying a text widget for a table item cell
      def edit_mode?
        !!@edit_mode
      end
      
      def cancel_edit!
        @cancel_edit&.call if @edit_mode
      end

      def finish_edit!
        @finish_edit&.call if @edit_mode
      end

      # Indicates if table is editing a table item because the user hit ENTER or focused out after making a change in edit mode to a table item cell.
      # It is set to false once change is saved to model
      def edit_in_progress?
        !!@edit_in_progress
      end
      
      def edit_selected_table_item(column_index, before_write: nil, after_write: nil, after_cancel: nil)
        edit_table_item(selection.first, column_index, before_write: before_write, after_write: after_write, after_cancel: after_cancel)
      end

        # TODO migrate the following to the next method
#       def edit_table_item(table_item, column_index)
#         table_item&.edit(column_index) unless column_index.nil?
#       end
      
      def edit_table_item(table_item, column_index, before_write: nil, after_write: nil, after_cancel: nil)
        return if table_item.nil? || (@edit_mode && @edit_table_item == table_item && @edit_column_index == column_index)
        @edit_column_index = column_index
        @edit_table_item = table_item
        column_index = column_index.to_i
        model = table_item.data
        property = column_properties[column_index]
        cancel_edit!
        return unless columns[column_index].editable?
        action_taken = false
        @edit_mode = true
        
        editor_config = columns[column_index].editor || editor
        editor_config = editor_config.to_collection
        editor_widget_options = editor_config.last.is_a?(Hash) ? editor_config.last : {}
        editor_widget_arg_last_index = editor_config.last.is_a?(Hash) ? -2 : -1
        editor_widget = (editor_config[0] || :text).to_sym
        editor_widget_args = editor_config[1..editor_widget_arg_last_index]
        model_editing_property = editor_widget_options[:property] || property
        widget_value_property = TableProxy::editors.symbolize_keys[editor_widget][:widget_value_property]
        
        @cancel_edit = lambda do |event=nil|
          @cancel_in_progress = true
          @table_editor.cancel!
          @table_editor_widget_proxy&.dispose
          @table_editor_widget_proxy = nil
          after_cancel&.call
          @edit_in_progress = false
          @cancel_in_progress = false
          @cancel_edit = nil
          @edit_table_item = @edit_column_index = nil if (@edit_mode && @edit_table_item == table_item && @edit_column_index == column_index)
          @edit_mode = false
        end
        
        @finish_edit = lambda do |event=nil|
          new_value = @table_editor_widget_proxy&.send(widget_value_property)
          if table_item.disposed?
            @cancel_edit.call
          elsif !new_value.nil? && !action_taken && !@edit_in_progress && !@cancel_in_progress
            action_taken = true
            @edit_in_progress = true
            if new_value == model.send(model_editing_property)
              @cancel_edit.call
            else
              before_write&.call
              @table_editor.save!(widget_value_property: widget_value_property)
              model.send("#{model_editing_property}=", new_value) # makes table update itself, so must search for selected table item again
              # Table refresh happens here because of model update triggering observers, so must retrieve table item again
              edited_table_item = search { |ti| ti.data == model }.first
              show_item(edited_table_item)
              @table_editor_widget_proxy&.dispose
              @table_editor_widget_proxy = nil
              after_write&.call(edited_table_item)
              @edit_in_progress = false
              @edit_table_item = @edit_column_index = nil
            end
          end
        end

        content {
          @table_editor_widget_proxy = TableProxy::editors.symbolize_keys[editor_widget][:editor_gui].call(editor_widget_args, model, model_editing_property, self)
        }
        @table_editor.set_editor(@table_editor_widget_proxy, table_item, column_index)
      rescue => e
        Glimmer::Config.logger.error {e.full_message}
        raise e
      end
      
      def show_item(table_item)
        table_item.dom_element.focus
      end
      
      def add_listener(underscored_listener_name, &block)
        enhanced_block = lambda do |event|
          event.extend(TableListenerEvent)
          block.call(event)
        end
        super(underscored_listener_name, &enhanced_block)
      end
              
      
      def header_visible=(value)
        @header_visible = value
        if @header_visible
          thead_dom_element.remove_class('hide')
        else
          thead_dom_element.add_class('hide')
        end
      end
      
      def header_visible
        @header_visible
      end
      
      def selector
        super + ' tbody'
      end
      
      def observation_request_to_event_mapping
        mouse_handler = -> (event_listener) {
          -> (event) {
            event.singleton_class.send(:define_method, :table_item=) do |item|
              @table_item = item
            end
            event.singleton_class.send(:define_method, :table_item) do
              @table_item
            end
            table_row = event.target.parents('tr').first
            table_data = event.target.parents('td').first
            event.table_item = items.detect {|item| item.id == table_row.attr('id')}
            event.singleton_class.send(:define_method, :column_index) do
              (table_data || event.target).attr('data-column-index')
            end
            
            event_listener.call(event) unless event.table_item.nil? && event.column_index.nil?
          }
        }

        {
          'on_mouse_down' => {
            event: 'mousedown',
            event_handler: mouse_handler,
          },
          'on_mouse_up' => {
            event: 'mouseup',
            event_handler: mouse_handler,
          },
          'on_widget_selected' => {
            event: 'mouseup',
            event_handler: mouse_handler,
          },
        }
      end
      
      def redraw
        super()
        @columns.to_a.each(&:redraw)
        redraw_empty_items
      end
      
      def redraw_empty_items
        if @children&.size.to_i < item_count.to_i
          item_count.to_i.times do
            empty_columns = column_properties&.size.to_i.times.map { |i| "<td data-column-index='#{i}'></td>" }
            items_dom_element.append("<tr class='table-item empty-table-item'>#{empty_columns}</tr>")
          end
        end
      end
      
      def element
        'table'
      end
      
      def columns_path
        path + ' thead tr'
      end

      def columns_dom_element
        Document.find(columns_path)
      end
      
      def items_path
        path + ' tbody'
      end

      def items_dom_element
        Document.find(items_path)
      end
      
      def columns_dom
        tr {
        }
      end
      
      def thead_dom
        thead {
          columns_dom
        }
      end
      
      def thead_dom_element
        dom_element.find('thead')
      end
      
      def items_dom
        tbody {
        }
      end
      
      def dom
        table_id = id
        table_id_style = css
        table_id_css_classes = css_classes
        table_id_css_classes << 'table' unless table_id_css_classes.include?('table')
        table_id_css_classes << 'editable' if editable? && !table_id_css_classes.include?('editable')
        table_id_css_classes_string = table_id_css_classes.to_a.join(' ')
        @dom ||= html {
          table(id: table_id, style: table_id_style, class: table_id_css_classes_string) {
            thead_dom
            items_dom
          }
        }.to_s
      end
      
      private

      def property_type_converters
        super.merge({
          selection: lambda do |value|
            if value.is_a?(Array)
              search {|ti| value.include?(ti.get_data) }
            else
              search {|ti| ti.get_data == value}
            end
          end,
        })
      end
      
    end
    
  end
  
end
