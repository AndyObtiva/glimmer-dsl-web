require 'glimmer/data_binding/observable_array'
require 'glimmer/data_binding/observable_model'
require 'glimmer/data_binding/observable'
require 'glimmer/data_binding/observer'
require 'glimmer/swt/table_proxy'
require 'glimmer/swt/table_item_proxy'

module Glimmer
  module DataBinding
    class TableItemsBinding
      include DataBinding::Observable
      include DataBinding::Observer

      def initialize(parent, model_binding, column_properties = nil)
        @last_populated_model_collection = nil
        @table = parent
        @model_binding = model_binding
        @column_properties = model_binding.binding_options[:column_attributes] || model_binding.binding_options[:column_properties] || column_properties # TODO
        @table.editable = false if model_binding.binding_options[:read_only]
        @table.data = @model_binding
        ##@table.on_widget_disposed do |dispose_event| # doesn't seem needed within Opal
        ##  unregister_all_observables
        ##end
        if @table.respond_to?(:column_properties=)
          @table.column_properties = @column_properties
        else # assume custom widget
         @table.body_root.column_properties = @column_properties
        end
        @table_observer_registration = observe(model_binding)
        call
      end

      def call(new_model_collection=nil)
        new_model_collection = @model_binding.evaluate_property # this ensures applying converters (e.g. :on_read)
        table_cells = @table.items.map {|item| @table.column_properties.size.times.map {|i| item.get_text(i)} }
        model_cells = new_model_collection.to_a.map {|m| @table.cells_for(m)}
        return if table_cells == model_cells
        if new_model_collection and new_model_collection.is_a?(Array)
          @table_items_observer_registration&.unobserve
          @table_items_observer_registration = observe(new_model_collection, @column_properties)
          add_dependent(@table_observer_registration => @table_items_observer_registration)
          @model_collection = new_model_collection
        end
        populate_table(@model_collection, @table, @column_properties)
        sort_table(@model_collection, @table, @column_properties)
      end
      
      def populate_table(model_collection, parent, column_properties)
        @skip_populate_table = model_collection&.sort_by(&:hash).map {|m| @table.column_properties.map {|p| m.send(p)}} == @last_populated_model_collection_properties
        return if @skip_populate_table
        @last_populated_model_collection = model_collection
        @last_populated_model_collection_properties = model_collection&.sort_by(&:hash).map {|m| @table.column_properties.map {|p| m.send(p)}}
        # TODO improve performance
        selected_table_item_models = parent.selection.map(&:get_data)
        old_items = parent.items
        old_item_ids_per_model = old_items.reduce({}) {|hash, item| hash.merge(item.get_data.hash => item.id) }
        parent.remove_all
        model_collection.each do |model|
          table_item = Glimmer::SWT::TableItemProxy.new(parent, [], nil)
          for index in 0..(column_properties.size-1)
            table_item.set_text(index, model.send(column_properties[index]).to_s)
          end
          table_item.set_data(model)
          table_item.id = old_item_ids_per_model[model.hash] if old_item_ids_per_model[model.hash]
        end
        parent.selection = parent.search {|item| selected_table_item_models.include?(item.get_data) }
        parent.redraw
      end
      
      def sort_table(model_collection, parent, column_properties)
        return if model_collection == @last_sorted_model_collection
        if model_collection == @last_populated_model_collection
          # Reapply the last table sort. The model collection has just been populated since it diverged from what it was before
          # TODO optimize in the future by sorting elements in DOM directly
          parent.sort!
        else
          # The model collection was sorted by the model, but beyond sorting, it did not change from the last populated model collection.
          parent.items = parent.items.sort_by { |item| model_collection.index(item.get_data) }
          @last_sorted_model_collection = @last_populated_model_collection = model_collection
        end
      end
    end
  end
end
