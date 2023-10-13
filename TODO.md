# TODO

Here is a list of tasks to do (moved to CHANGELOG.md once done).

## Next (0.0.2)

- Add Hello, World! sample as a Ruby file (not just in README)
- Component support (aka custom element)
- Support JS listeners like `onclick`
- Hello, Button! sample

## 0.0.3

- <%= glimmer_component("glimmer_subdirectory/component_name", **options) %>

## 0.0.4

- Simple attribute unidirectional/bidirectional data-binding

## 0.0.5

- Shortened unidirectional data-binding syntax (useful for inner_html property as it requires hierarchical markup as content)
inner_html(*data_binding_options) { |data_binding_value|
  span {
    data_binding_value
  }
}

## Soon

- Consider using descendants_tracker gem instead of implementing descendants manually
- Glimmer Engine with `GlimmerHelper#glimmer_component`
- Content Generators

## Future

- Support Ruby WASM: https://github.com/ruby/ruby.wasm

## Maybe

## Issues

## Samples
