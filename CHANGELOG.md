# Change Log

## 0.0.3

- Set Glimmer specific element attributes (e.g. `parent`) as data attributes on generated HTML elements
- Support setting text content by passing as first argument to an element as an alternative to block return value
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
