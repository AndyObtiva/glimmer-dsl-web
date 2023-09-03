require 'glimmer/dsl/engine'
# Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f}
require 'glimmer/dsl/opal/shell_expression'
require 'glimmer/dsl/opal/widget_expression'
require 'glimmer/dsl/opal/property_expression'
require 'glimmer/dsl/opal/bind_expression'
require 'glimmer/dsl/opal/data_binding_expression'
require 'glimmer/dsl/opal/display_expression'
require 'glimmer/dsl/opal/combo_selection_data_binding_expression'
require 'glimmer/dsl/opal/widget_listener_expression'
require 'glimmer/dsl/opal/message_box_expression'
require 'glimmer/dsl/opal/async_exec_expression'
require 'glimmer/dsl/opal/sync_exec_expression'
require 'glimmer/dsl/opal/observe_expression'
require 'glimmer/dsl/opal/layout_expression'
require 'glimmer/dsl/opal/layout_data_expression'
require 'glimmer/dsl/opal/list_selection_data_binding_expression'
require 'glimmer/dsl/opal/table_items_data_binding_expression'
require 'glimmer/dsl/opal/column_properties_expression'
require 'glimmer/dsl/opal/font_expression'
require 'glimmer/dsl/opal/color_expression'
require 'glimmer/dsl/opal/rgb_expression'
require 'glimmer/dsl/opal/rgba_expression'
require 'glimmer/dsl/opal/custom_widget_expression'
require 'glimmer/dsl/opal/swt_expression'
require 'glimmer/dsl/opal/radio_group_selection_data_binding_expression'
require 'glimmer/dsl/opal/checkbox_group_selection_data_binding_expression'
require 'glimmer/dsl/opal/block_property_expression'
require 'glimmer/dsl/opal/menu_expression'
require 'glimmer/dsl/opal/dialog_expression'
require 'glimmer/dsl/opal/shape_expression'
require 'glimmer/dsl/opal/shine_data_binding_expression'
require 'glimmer/dsl/opal/shape_expression'
require 'glimmer/dsl/opal/image_expression'

module Glimmer
  module DSL
    module Opal
      Engine.add_dynamic_expressions(
       Opal,
       %w[
         custom_widget
         widget_listener
         table_items_data_binding
         combo_selection_data_binding
         list_selection_data_binding
         radio_group_selection_data_binding
         checkbox_group_selection_data_binding
         data_binding
         font
         image
         layout
         block_property
         property
         shine_data_binding
         shape
         widget
       ]
      )
    end
  end
end
