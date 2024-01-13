# Change Log

## 0.2.3

- Alias `Kernel#p` as `Kernel#pi` (puts inspect) to allow using `pi` in place of `p` for printing inspected objects given that `p` is used up by the HTML DSL.
- Remove `element` from dynamic part of Glimmer DSL to allow it to fail faster if an invalid HTML element name was used

## 0.2.2

- Fix bug in content data-binding that was caused by recent performance optimizations (+ fix Hello, Content Data-Binding! sample)
- Fix bug in rendering formatting elements that was caused by recent performance optimizations (+ fix Hello, Paragraph! sample)

## 0.2.1

- Optimize performance (~800% faster):
  - Optimize performance (~20% faster than 0.2.0) by not using glimmer-dsl-xml for rendering dom elements in the frontend as it is more suitable for backend rendering and we already have a separate dsl for the frontend
  - Optimize performance (~287% faster than previous bullet point) by adding Glimmer shortcut methods for all HTML element DSL keywords
  - Optimize performance (~235% faster than previous bullet point) by not selecting ElementProxy subclass dynamically for each element, yet always using ElementProxy

## 0.2.0

- Support `style` element content as Glimmer DSL for CSS syntax (Ruby Programmable CSS) as an alternative to a CSS `String`

## 0.1.1

- Upgrade to opal-jquery 0.5.1 (adds `# backtick_javascript: true` where needed to satisfy new Opal requirement)
- Upgrade to opal-async 1.4.1 (adds `# backtick_javascript: true` where needed to satisfy new Opal requirement)
- Update setup instructions to NOT disable Hotwire files, to allow running Hotwire/Turbo side by side with Glimmer DSL for Web (but not in the same pages)

## 0.1.0

- Update rendering system to render HTML elements immediately instead of waiting for complete components to be rendered all at once.
- Support `render: false` option in any element or component to avoid rendering when building the elements/components (including a Component#create alternative to Component#render that defers rendering if needed).
- Fix `Glimmer::Web::Component` `after_render` hook by ensuring it only fires after the component markup has been rendered

## 0.0.12

- Treat HTML text formatting elements differently (e.g. `b`, `i`, `strong`, `em`, `sub`, `sup`, `del`, `ins`, `small`, `mark`) by not appending to their parent content, yet having them generate a String with `to_s` that can be embedded in a `String` that is the text content of another normal element like `p` or `div`.
- Treat `span` as a special text formatting element if included inside a `p` and as a normal element outside a `p`.
- Hello, Paragraph! Sample: `require 'glimmer-dsl-web/samples/hello/hello_paragraph'`

## 0.0.11

- Support element custom event listener: `on_remove`
- Support `observe` keyword to observe Model attributes in Views with a convenient DSL keyword.
- Clean observers declared with `observe` keyword inside a component when `component.markup_root.remove` is called (or equivalent `component.remove` is called).
- Update `glimmer_component` to render its content immediately without waiting for `Document.ready?` as that is not necessary given its container is added to the DOM immediately
- Upgrade jquery-opal to 0.5.0 (latest version)
- Hello, Observer! Sample: `require 'glimmer-dsl-web/samples/hello/hello_observer'`
- Button Counter Sample: `require 'glimmer-dsl-web/samples/regular/button_counter'`

## 0.0.10

- Glimmer Component Rails Helper (add `include GlimmerHelper` to `ApplicationHelper` or another Rails helper) and use `<%= glimmer_component("path/to/component", *args) %>` in Views
- Support passing args to Components via `ComponentClassName.render(*args)`
- Update `element#render` API to require `:parent` kwarg to pass parent selector (no longer accepting parent selector directly as first arg)
- Upgrade to opal 1.8.2 (latest version)
- Upgrade to opal-rails 2.0.3 (latest version)
- Change setup instructions to avoid relying on `app/assets/javascript/application.js.rb`, yet instead rename to `app/assets/opal/application.rb` and rely on `app/assets/opal` for Opal frontend files.

## 0.0.9

- Component support (View component classes simply `include Glimmer::Web::Component`)
- Improve README.md setup instructions, documenting how to enable Browser Opal Debugging in Ruby using Opal Source Maps
- Allow passing element `:parent` selector through `render` method as first argument (`render(selector)`) for a potentially more readable second way of doing the same thing
- Fix Hello, Content Data-Binding! as it forgot to include Glimmer to top-level main object and forgot to wait for Document.ready?
- New Hello, Component! Sample: `require 'glimmer-dsl-web/samples/hello/hello_component'`

## 0.0.8

- Validate that element keywords belong to the valid list of HTML element tag names to prevent rendering fake elements the keyword does not match a real HTML element tag
- Support inner_html/outer_html properties (it seems they did not convert to innerHTML/outerHTML correctly because of the all caps HTML)
- Support element properties via original JS names (e.g. innerHTML) to prevent logic from breaking if some do not convert correctly from underscored versions
- Package dependencies properly in the gem to avoid instructing users to add in Rails Gemfile manually
- Content Data-Binding support to regenerate element content based on changes to an observed model attribute.
Content Data-Binding Example:
content(*data_binding_options) { |data_binding_value|
  li {
    data_binding_value
  }
}
- Ensuring removing data-binding model listeners when calling `element#remove` in addition to already removing standard HTML event listeners
- New Hello, Content Data-Binding! Sample: `require 'glimmer-dsl-web/samples/hello/hello_content_data_binding'`

## 0.0.7

- Support input[type=number] value data-binding as a Ruby Numeric object (Integer or Float)
- Support input[type=range] value data-binding as a Ruby Numeric object (Integer or Float)
- Support input[type=datetime-local] value data-binding as a Ruby Time object
- Support input[type=date] value data-binding as a Ruby Date object
- Support input[type=time] value data-binding as a Ruby Time object
- Update Hello, Data-Binding! Sample to include a checkbox
- New Hello, Input (Date/Time)! Sample: `require 'glimmer-dsl-web/samples/hello/hello_input'`

## 0.0.6

- Support attribute unidirectional/bidirectional data-binding
- Support `select` element (it was blocked by a built-in Ruby method)
- Handle case of `:parent` selector being invalid, defaulting to `body`.
- Remove pure-struct gem dependency as the latest Opal fixed the implementation of Struct
- New Hello, Data-Binding! Sample: `require 'glimmer-dsl-web/samples/hello/hello_data_binding'`

## 0.0.5

- Support `p` element as it was overriden by Ruby's `p` method.
- Update listener syntax to be the original HTML event name (e.g. `onclick`) without being underscored to keep the transition to the Glimmer GUI DSL simple (e.g. `onclick` not `on_click`)
- Wrap listener `event` argument with `Glimmer::Web::Event` object, which proxies calls to JS event when needed
- Rename Hello Button! Sample to Hello, Form! Sample: `require 'glimmer-dsl-web/samples/hello/hello_form'`
- Update Hello, Form! Sample to display browser native validation errors and have automatic focus support on the name field
- Event listeners do not call `prevent_default` by default anymore, leaving it to the consumer of the library to decide
- New Hello, Button! Sample (replacing older one): `require 'glimmer-dsl-web/samples/hello/hello_button'`

## 0.0.4

- Support nesting attributes/properties under element (e.g. `input { value 'something'; dir 'rtl' }`)
- Ensure when calling `element#remove`, all its listeners and children are removed cleanly too (e.g. calling `button.remove` automatically unregisters `on_click` listener)

## 0.0.3

- Set Glimmer specific element attributes (e.g. `parent`) as data attributes on generated HTML elements
- Support setting text content by passing as first argument to an element as an alternative to block return value
- Proxy method/attribute invocations on an element to its HTML element (e.g. `input_element.check_validity` proxies to `checkValidity` JS function)
- Support JS listeners like `onclick` by nesting an `on_someeventname` block under an element (e.g. `on_click { ... }`)
- New Hello, Button! Sample: `require 'glimmer-dsl-web/samples/hello/hello_button'`

## 0.0.2

- Rename element `:root` option to `:parent` option
- Set `body` as parent by default if `:parent` option is not specified for a root element
- Set `class` instead of `id` on generated HTML elements to identify them (e.g. `element-2`).
- New Hello, World! Sample: `require 'glimmer-dsl-web/samples/hello/hello_world'`

## 0.0.1

- Render top-level HTML element + attributes under a root parent element by specifying `root: 'css_selector'` option (e.g. `div(root: 'css_selector')`)
- Render nested HTML element + attributes by nesting under another HTML element (`div(root: 'css_selector') { span }`)
- Render `String` text content as the return value of the block of an HTML element (`div(root: 'css_selector') { "Hello, World!" }`)
