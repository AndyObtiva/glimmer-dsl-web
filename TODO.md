# TODO

Here is a list of tasks to do (moved to CHANGELOG.md once done).

## Next

- Proxy method and attribute invocations on an element to the HTML element (like `input.value`) or maybe proxy to jQuery element only
- Support JS listeners like `onclick` by nesting an `on_someeventname` block under an element

## 0.0.4

- Simple attribute unidirectional/bidirectional data-binding

## 0.0.5

- Content data-binding support:
content(*data_binding_options) { |data_binding_value|
  span {
    data_binding_value
  }
}

## 0.0.6

- Component support (aka custom element)

## 0.0.7

- Glimmer Rails Engine to support `GlimmerHelper#glimmer_component`
- <%= glimmer_component("glimmer_subdirectory/component_name", **options) %>

## Soon

- Consider using descendants_tracker gem instead of implementing descendants manually

## Future

- Support Ruby WASM: https://github.com/ruby/ruby.wasm
- JavaScript Canvas API

## Maybe

## Issues

## Samples
