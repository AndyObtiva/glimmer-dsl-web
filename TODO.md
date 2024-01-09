# TODO

Here is a list of tasks to do (moved to CHANGELOG.md once done).

## Next

### 0.2.x

- Add an example of talking to web APIs to populate GUI data via read-only ajax requests
- Add an example of form submitting via ajax request
- Add an example of a multi-page form wizard with breadcrumbs and step numbers while submitting a form via Ajax after filling every page

### 0.3.0

- Implement `inspect` method for library classes like `ElementProxy`, `ListenerProxy`, and `EventProxy` (especially) to help with troubleshooting.
- Implement `methods` for `EventProxy` given that it pulls most of its method names dynamically through method_missing
- Implement `methods` for `ElementProxy` given that it pulls most of its method names dynamically through method_missing
- Use descendants_tracker gem instead of implementing descendants manually
- Document how to reuse Ruby code both server-side (backend) and client-side (frontend)
- Document Style Guide of Glimmer DSL for Web (partially borrowed from Glimmer libui library)
- svg example
- Consider keeping track of all Glimmer rendered elements on the page as Ruby view objects to be able to remove them cleanly including their observers
- Alert user if they attempt to build a component that shadows an HTML element
- Consider renaming `element-ID` css classes to `glimmer_element_ID` for a more unique class name that nobody else would be using
- Consider removing `element` css class from elements except the root, and maybe rename the css class to `glimmer_element_root`
- Provide a simpler way of defining custom listeners on Componenets than overriding handle_listener_request and can_handle listener request
  
### 1.0.0

- Router support to enable friendly URLs when needed
Example:
  route '#hello-world' do
    require 'glimmer-dsl-web/samples/hello/hello_world.rb'
  end

  route do
    div {
      button('Run Hello, World! Sample') {
        onclick do
          Glimmer::Web::Router.visit('#hello-world')
        end
      }
    }
  end

### 1.1.0

- Generate backend Rails views with Glimmer DSL for XML syntax as a Ruby alternative to ERB

### 2.0.0

- Support Ruby WASM: https://github.com/ruby/ruby.wasm
- Consider removing Opal-jQuery if possible switching to pure JS Document calls via Opal, to allow supporting WASM with technology neutral code

## Future

- JavaScript Canvas API
- Build a HTML to Glimmer GUI DSL converter to enable Software Engineers to reuse older HTML in a Glimmer DSL for Web app
- Contribute to Opal-Rails change to create app/assets/opal/application.rb instead of app/assets/javascript/application.js.rb as the latter is confusing (or at least an option)

## Maybe

- Implement `DateTime#strptime` & `Date#strptime` (unless the Opal project beats me to it)
- Support data-binding fine-grained `style` CSS properties on element more conveniently like with `style.background somevalue`, `style-background somevalue`, `style { background something }`, or something similar.
- `labeled_input` custom control (or simply support label as an option in `input`)
- Consider supporting higher abstraction flavors of data-binding for various elements like `table` and `select`
- Consider supporting input and textarea data-binding changes on focus out (onblur) instead of direct onchange, by specifying an extra option
- Consider supporting input and textarea built-in debounce (not firing change to model till the user stopped typing for a period of time) [and explore a way to allow people to support any write/read strategy as part of this]
- Consider preventing `ElementProxy` from returning `nil` if an invalid method name was invoked (like `vali`). It seems today, it works, but returns `nil`. Maybe, have it error out instead.
- Consider using element.method format in DSL to generate an element with a class (or element_class__id)
- Consider supporting an automatic router (auto-generates history based on user actions). Not sure if we have to remember the full DOM or full Ruby Glimmer GUI DSL structure of every change and replay different pages based on that information when a route is entered or the user hits the back/forward buttons.
- Consider having form validation auto-setup by model validations using ActiveModel::Model, ActiveRecord (porting to the frontend), HyperStack, or something similar (provided by Glimmer if needed).
- Consider idea of setting a different default ID for rendering other than `body` (that could be set globally or temporarily in a scope)
- Consider optionally supporting 2nd arg of `option` in `Component` as `:default`
- Support setting element `style` CSS properties with Glimmer DSL for CSS when using the nested property version (assuming Glimmer DSL for CSS underwent some improvements as per its TODO next items)
- Build a Rails generator for installing this gem properly in a Rails app
- Consider the idea of having Formatting Elements actually return elements, not strings, but with a properly implemented `to_s` method.
- As an optimization in Content Data-Binding, consider saving rendered DOMs per model attribute values and reshowing them instead of recreating them.
- As an optimization in Content Data-Binding, consider diffing, removing all listeners and re-installing listeners on the same elements.
- Consider optimizing component rendering by pre-generating a component template, and copying (if/else conditions are simulated with show/hide on an element)
- Consider generating a nonce for style tags (elements)
- Consider ensuring display of elements immediately upon render by using setTimeout to render them (and perhaps limit that to 2nd level under root to avoid being too fine grained). Or you can have it render by accumulation count setting (like every 100 elements or every 1000 elements). Or you can do special rendering for controls that are known to contain a lot of things like `table`.
- Generate Rails scaffolding directly with Glimmer GUI DSL code
- Support backend Glimmer GUI DSL syntax as a replacement for ERB (using Glimmer DSL for XML)
- Optimize performance of registering dom listeners by including real oneveny attributes where that works tgat would register the listener in first use. This works in tandem witj building html for all dom elements at once for much faster initial rendering
- Consider optimizing performance by building GUI with a render call that assembles html from all nested elements all at once

## Issues

- Figure out why when an error occurs, a glimmer component is rendered twice

## Samples

- Sample showing a progress bar or progress circle

## Samples
