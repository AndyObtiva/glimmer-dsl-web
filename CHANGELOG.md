# Change Log

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
