module GlimmerHelper
  class << self
    def next_id_number
      @next_id_number ||= 0
      @next_id_number += 1
    end
  end
  
  def glimmer_component(component_asset_path, *component_args)
    normalize_active_record_relation_option_values!(component_args.last)
    component_file = component_asset_path.split('/').last # TODO support namespaced components
    component_class_name = component_file.classify # TODO support namespaced components
    next_id_number = GlimmerHelper.next_id_number
    component_id = "glimmer_component_#{next_id_number}"
    component_script_container_id = "glimmer_component_script_container_#{next_id_number}"
    component_script_tag_id = "glimmer_component_script_#{next_id_number}"
    component_args_json = JSON.dump(component_args)
    opal_script = <<~OPAL
      require 'glimmer-dsl-web'
      component_args_json = $$.document.getElementById("#{component_script_tag_id}").dataset.componentArgs
      component_args = JSON.parse(component_args_json)
      component_args << {} if !component_args.last.is_a?(Hash)
      component_args.last[:parent] = "##{component_id}"
      #{component_class_name}.render(*component_args)
    OPAL
    js_script = <<~JAVASCRIPT
      Opal.eval(`#{opal_script}`)
    JAVASCRIPT
    content_tag(:div, id: component_script_container_id, class: ['glimmer_component_script_container', "#{component_file}_script_container"], 'data-turbo': 'false') do
      content_tag(:div, '', id: component_id, class: ['glimmer_component', component_file]) +
      javascript_include_tag(component_asset_path, "data-turbolinks-track": "reload") +
      content_tag(:script, raw(js_script), id: component_script_tag_id, type: 'application/javascript', "data-turbo-eval": "false", "data-component-args": component_args_json)
    end
  end
    
  private
  
  def normalize_active_record_relation_option_values!(option_values)
    option_values&.each do |key, value|
      if value.is_a?(ActiveRecord::Relation)
        models = value.to_a
        models = models.map do |model|
          if model.is_a?(ActiveRecord::Base)
            model.as_json
          else
            model
          end
        end
        option_values[key] = models
      elsif value.is_a?(ActiveRecord::Base)
        option_values[key] = value.as_json
      end
    end
  end
end
