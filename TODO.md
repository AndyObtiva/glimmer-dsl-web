# TODO

Here is a list of tasks to do (moved to CHANGELOG.md once done).

## Next

### 0.0.x

- Content data-binding support:
content(*data_binding_options) { |data_binding_value|
  span {
    data_binding_value
  }
}

### 0.0.x

- Component support (aka custom element)
- Consider changing where we pass parent selector, making it `render(selector)` method

### 0.0.x

- Glimmer Rails Engine to support `GlimmerHelper#glimmer_component`
- <%= glimmer_component("glimmer_subdirectory/component_name", **options) %>

### 0.0.x

- Treat HTML text formatting elements differently (e.g. `b`, `i`, `strong`, `em`, `sub`, `sup`, `del`, `ins`, `small`, `mark`) by not appending to their parent content, yet having them generate a String with `to_s` that can be embedded in a `String` that is the text content of another normal element like `p` or `div`.
- Treat `span` as a special text formatting element if included inside a `p` and as a normal element outside a `p`.

### 0.1.0

- Automatic cleanup of element observers upon calling element.remove & Automatic cleanup of data-binding observers upon calling element.remove
- Add examples of talking to web APIs to populate GUI data via read-only ajax requests
- Add examples of form submitting via ajax request

### 1.0.0

- Support setting element `style` CSS properties with Glimmer DSL for CSS when using the nested property version (assuming Glimmer DSL for CSS underwent some improvements as per its TODO next items)
- Support a manual router (to enable friendly URLs when needed)
- Support an automatic router (auto-generates history based on user actions)
- Implement `inspect` method for library classes like `ElementProxy`, `ListenerProxy`, and `EventProxy` (especially) to help with troubleshooting.
- Implement `methods` for `EventProxy` given that it pulls most of its method names dynamically through method_missing
- Implement `methods` for `ElementProxy` given that it pulls most of its method names dynamically through method_missing
- Use descendants_tracker gem instead of implementing descendants manually
- Try to package dependencies as gem dependencies instead of asking people to add in Rails Gemfile manually
- Document how to reuse server-side Ruby code (backend) client-side (frontend)
- Document principles of Glimmer DSL for Web (partially borrowed from Glimmer libui and opal libraries)
- Document Style Guide of Glimmer DSL for Web (partially borrowed from Glimmer libui library)
- Implement `DateTime#strptime` & `Date#strptime`

### 2.0.0

- Support Ruby WASM: https://github.com/ruby/ruby.wasm
- Consider removing Opal-jQuery if possible switching to pure JS Document calls via Opal, to allow supporting WASM with technology neutral code

## Future

- JavaScript Canvas API
- Build a HTML to Glimmer GUI DSL converter to enable Software Engineers to reuse older HTML in a Glimmer DSL for Web app

## Maybe

- Support data-binding fine-grained `style` CSS properties on element more conveniently like with `style.background somevalue`, `style-background somevalue`, `style { background something }`, or something similar.
- `labeled_input` custom control (or simply support label as an option in `input`)
- Consider supporting higher abstraction flavors of data-binding for various elements like `table` and `select`
- Consider supporting input and textarea data-binding changes on focus out (onblur) instead of direct onchange, by specifying an extra option
- Consider supporting input and textarea built-in debounce (not firing change to model till the user stopped typing for a period of time) [and explore a way to allow people to support any write/read strategy as part of this]
- Support custom listeners on elements
- Consider preventing `ElementProxy` from returning `nil` if an invalid method name was invoked (like `vali`). It seems today, it works, but returns `nil`. Maybe, have it error out instead.

## Issues

## Samples
