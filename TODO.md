# TODO

Here is a list of tasks to do (moved to CHANGELOG.md once done).

## Next

- Support JS listeners like `onclick` by nesting an `on_someeventname` block under an element
- Hello, Button! sample

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

- <%= glimmer_component("glimmer_subdirectory/component_name", **options) %>

## Soon

- Consider using descendants_tracker gem instead of implementing descendants manually
- Glimmer Engine with `GlimmerHelper#glimmer_component`
- Content Generators

## Future

- Support Ruby WASM: https://github.com/ruby/ruby.wasm

## Maybe

## Issues

## Samples
