# TODO

Here is a list of tasks to do (moved to CHANGELOG.md once done).

## Next

### 0.0.x

- Document principles of Glimmer DSL for Web (partially borrowed from Glimmer libui and opal libraries)
- Document Style Guide of Glimmer DSL for Web (partially borrowed from Glimmer libui library)

### 0.1.0

warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- async/timeout.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- async/interval.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- async/countdown.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- async/task.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- opal/jquery/window.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- opal/jquery/element.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- opal/jquery/constants.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- opal/jquery/document.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- opal/jquery/event.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- opal/jquery/http.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- opal/jquery/kernel.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- opal/jquery/local_storage.rb:
warning: Backtick operator usage interpreted as intent to embed JavaScript; this code will break in Opal 2.0; add a magic comment: `# backtick_javascript: true` -- glimmer/web/event_proxy.rb:
- Treat HTML text formatting elements differently (e.g. `b`, `i`, `strong`, `em`, `sub`, `sup`, `del`, `ins`, `small`, `mark`) by not appending to their parent content, yet having them generate a String with `to_s` that can be embedded in a `String` that is the text content of another normal element like `p` or `div`.
- Treat `span` as a special text formatting element if included inside a `p` and as a normal element outside a `p`.
- Consider immediate rendering instead of using `render` keyword, or giving the option to render things hidden and then show them at the end. (maybe add `render: false` element option)
- Consider revising rendering system so that it does not wait for rendering everything, yet it would render parents right away, and then add to them
- It is incorrect to call before_render and after_render on component. .they're before_markup and afteR_markup

### 0.1.x

- Add an example of talking to web APIs to populate GUI data via read-only ajax requests
- Add an example of form submitting via ajax request
- Add an example of a multi-page form wizard with breadcrumbs and step numbers while submitting a form via Ajax after filling every page
 
### 1.0.0

- Support setting element `style` CSS properties with Glimmer DSL for CSS when using the nested `style` element (assuming Glimmer DSL for CSS underwent some improvements as per its TODO next items)
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
- Implement `inspect` method for library classes like `ElementProxy`, `ListenerProxy`, and `EventProxy` (especially) to help with troubleshooting.
- Implement `methods` for `EventProxy` given that it pulls most of its method names dynamically through method_missing
- Implement `methods` for `ElementProxy` given that it pulls most of its method names dynamically through method_missing
- Use descendants_tracker gem instead of implementing descendants manually
- Document how to reuse server-side Ruby code (backend) client-side (frontend)
- Implement `DateTime#strptime` & `Date#strptime`
- svg example
- Consider keeping track of all Glimmer rendered elements on the page as Ruby view objects to be able to remove them cleanly including their observers
- Consider keeping track of glimmer_component ID on the rendered component (though currently we can use parent to find it)

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
- Consider using element.method format in DSL to generate an element with a class (or element_class__id)
- Consider supporting an automatic router (auto-generates history based on user actions). Not sure if we have to remember the full DOM or full Ruby Glimmer GUI DSL structure of every change and replay different pages based on that information when a route is entered or the user hits the back/forward buttons.
- Consider having form validation auto-setup by model validations using ActiveModel::Model, ActiveRecord (porting to the frontend), HyperStack, or something similar (provided by Glimmer if needed).
- Consider idea of setting a different default ID for rendering other than `body` (that could be set globally or temporarily in a scope)
- Consider optionally supporting 2nd arg of `option` in `Component` as `:default`
- Support setting element `style` CSS properties with Glimmer DSL for CSS when using the nested property version (assuming Glimmer DSL for CSS underwent some improvements as per its TODO next items)
- Build a Rails generator for installing this gem properly in a Rails app
- Provide a simpler way of defining custom listeners on Componenets than overriding handle_listener_request and can_hanlde listener request

## Issues

## Samples
