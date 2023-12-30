# TODO

Here is a list of tasks to do (moved to CHANGELOG.md once done).

## Next

### 0.0.5

- Wrap listener event argument with Glimmer Ruby Event object
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

### 0.0.9

- Treat HTML text formatting elements differently (e.g. `b`, `i`, `strong`, `em`, `sub`, `sup`, `del`, `ins`, `small`, `mark`) by not appending to their parent content, yet having them generate a String with `to_s` that can be embedded in a `String` that is the text content of another normal element like `p` or `div`.
- Treat `span` as a special text formatting element if included inside a `p` and as a normal element outside a `p`.

## Soon

- Consider using descendants_tracker gem instead of implementing descendants manually
- Remove pure-struct if no longer needed
= Remove jQuery if possible switching to pure JS Document calls via Opal
- Support custom listeners on elements
- Support setting `style` CSS properties on element more conveniently like with `style.background somevalue`, `style-background somevalue`, `style { background something }`, or something similar.

## Future

- Support Ruby WASM: https://github.com/ruby/ruby.wasm
- JavaScript Canvas API

## Maybe

## Issues

## Samples
