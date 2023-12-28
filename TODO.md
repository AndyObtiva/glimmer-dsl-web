# TODO

Here is a list of tasks to do (moved to CHANGELOG.md once done).

## Next

### 0.0.4

- Support cleanup of listeners when an element is deleted
- Support element attributes by nest attributes and their values under an element (e.g. `input { value 'something' }`)

### 0.0.5

- Simple attribute unidirectional/bidirectional data-binding

### 0.0.6

- Content data-binding support:
content(*data_binding_options) { |data_binding_value|
  span {
    data_binding_value
  }
}

### 0.0.7

- Component support (aka custom element)

### 0.0.8

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
