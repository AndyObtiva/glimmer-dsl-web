module GlimmerHelper
  class << self
    def next_id_number
      @next_id_number ||= 0
      @next_id_number += 1
    end
  end
  
  def uncached_glimmer_component(component_asset_path, *component_args)
    component_file = component_asset_path.split('/').last # TODO support namespaced components
    component_class_name = component_file.classify # TODO support namespaced components
    next_id_number = GlimmerHelper.next_id_number
    component_id = "glimmer_component_#{next_id_number}"
    component_script_container_id = "glimmer_component_script_container_#{next_id_number}"
    component_args_json = JSON.dump(component_args)
    opal_script = <<~OPAL
      require 'glimmer-dsl-web'
      component_args_json = '#{component_args_json}'
      component_args = JSON.parse(component_args_json)
      component_args << {} if !component_args.last.is_a?(Hash)
      component_args.last[:parent] = "##{component_id}"
      #{component_class_name}.render(*component_args)
    OPAL
    js_script = Opal.compile(opal_script, file: "(glimmer-component-#{next_id_number})", load: true)
    content_tag(:div, id: component_script_container_id, class: ['glimmer_component_script_container', "#{component_file}_script_container"], 'data-turbo': 'false') do
      content_tag(:div, '', id: component_id, class: ['glimmer_component', component_file]) +
      javascript_include_tag(component_asset_path, "data-turbolinks-track": "reload") +
      content_tag(:script, raw(js_script), type: 'application/javascript', "data-turbo-eval": "false")
    end
  end

  def glimmer_component(component_asset_path, *component_args)
    @_cached_glimmer_components ||= {}
    @_cached_glimmer_components[[component_asset_path, component_args]] ||=
      uncached_glimmer_component(component_asset_path, *component_args)
  end
end
