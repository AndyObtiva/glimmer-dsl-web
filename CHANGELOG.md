# Change Log

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
