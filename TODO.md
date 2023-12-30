# TODO

Here is a list of tasks to do (moved to CHANGELOG.md once done).

## Next

### 0.0.6

- Content data-binding support:
content(*data_binding_options) { |data_binding_value|
  span {
    data_binding_value
  }
}
- Document capabilities like reusing serverside code and principles of Glimmer DSL for Web (some borrowed from Glimmer libui library)
- Add a Glimmer Meta-Sample app

### 0.0.7

- Component support (aka custom element)
- Consider changing where we pass parent selector, making it `render(selector)` method

### 0.0.8

- Glimmer Rails Engine to support `GlimmerHelper#glimmer_component`
- <%= glimmer_component("glimmer_subdirectory/component_name", **options) %>

### 0.0.9

- Treat HTML text formatting elements differently (e.g. `b`, `i`, `strong`, `em`, `sub`, `sup`, `del`, `ins`, `small`, `mark`) by not appending to their parent content, yet having them generate a String with `to_s` that can be embedded in a `String` that is the text content of another normal element like `p` or `div`.
- Treat `span` as a special text formatting element if included inside a `p` and as a normal element outside a `p`.

## Soon

- Consider using descendants_tracker gem instead of implementing descendants manually
= Remove jQuery if possible switching to pure JS Document calls via Opal
- Support custom listeners on elements
- Support setting `style` CSS properties on element more conveniently like with `style.background somevalue`, `style-background somevalue`, `style { background something }`, or something similar.
- Add examples of form submitting via ajax request
- Add examples of talking to web APIs to populate GUI data via ajax requests
- Implement `inspect` method for library classes like `ElementProxy`, `ListenerProxy`, and `EventProxy` (especially) to help with troubleshooting.
- Implement `methods` for `EventProxy` given that it pulls most of its method names dynamically through method_missing
- Implement `methods` for `ElementProxy` given that it pulls most of its method names dynamically through method_missing
- Try to package dependencies as gem dependencies instead of asking people to add in Rails Gemfile manually
- Automatic cleanup of element observers upon calling element.remove & Automatic cleanup of data-binding observers upon calling element.remove
- Support an automatic router and a manual router

## Future

- Support Ruby WASM: https://github.com/ruby/ruby.wasm
- JavaScript Canvas API
- Improvements in Glimmer DSL for CSS
- Build a HTML to Glimmer GUI DSL converter to enable Software Engineers to reuse older HTML in a Glimmer DSL for Web app

## Maybe

- Consider supporting higher abstraction flavors of data-binding for various elements like `table` and `select`
- Consider supporting data-binding changes on focus out instead of direct change, by specifying an extra option

## Issues

## Samples
