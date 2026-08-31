# Rails 7 Setup (Sprockets pipeline)

This is the legacy Rails 7 + Sprockets/request-time compilation setup, where Sprockets both compiles and serves the Opal assets.

If you want the newer Rails 7/8 build/watch flow, use [rails_7_8_build_pipeline.md](rails_7_8_build_pipeline.md) instead. That newer flow can still run in a Rails app that uses Sprockets, but in that case Sprockets only serves files already built into `app/assets/builds`.

This guide requires pinning `opal-rails` to the Sprockets-era line:

```ruby
gem 'opal-rails', '~> 2.0.4'
```

Do not use the newer build-pipeline `opal-rails` branch with the setup below without porting the app deliberately.

If you want to migrate an existing app from this legacy setup to the newer build/watch pipeline, use [rails_7_8_build_pipeline.md](rails_7_8_build_pipeline.md) together with the `opal-rails` porting notes: https://github.com/opal/opal-rails/blob/master/PORTING.md

## Setup

Install a Rails 7 gem:

```bash
gem install rails -v 7.0.8.6
```

Start a new Rails 7 app:

```bash
rails _7.0.8.6_ new glimmer_app_server
```

Add the following to `Gemfile`:

```ruby
gem 'glimmer-dsl-web', '~> 0.10.3'
gem 'opal-rails', '~> 2.0.4'
```

Run:

```bash
bundle
```

If you upgrade your `glimmer-dsl-web` gem version later, clear the Opal cache from inside your Rails app first:

```bash
rm -rf tmp/cache
```

Follow the legacy `opal-rails` instructions, basically running:

```bash
bin/rails g opal:install
```

To enable the `glimmer-dsl-web` gem in the frontend, edit `config/initializers/assets.rb` and add the following at the bottom (this also requires creating `manifest.opal.js` later in the guide):

```ruby
Opal.use_gem 'glimmer-dsl-web'
Opal.append_path Rails.root.join('app', 'assets', 'opal')
Rails.application.config.assets.precompile += %w[manifest.opal.js]
```

To enable Opal browser debugging in Ruby with [Source Maps](https://opalrb.com/docs/guides/v1.4.1/source_maps.html), edit `config/initializers/opal.rb` and add the following inside the `Rails.application.configure do ... end` block:

```ruby
  config.assets.debug = true if Rails.env.development?
```

Assuming this is a brand new Rails application and you do not have any Rails resources yet, scaffold a welcome resource just for testing purposes.

Run:

```bash
bin/rails g scaffold welcome
bin/rails db:migrate
```

Add the following to `config/routes.rb` inside the `Rails.application.routes.draw` block:

```ruby
root to: 'welcomes#index'
```

Clear the file `app/views/welcomes/index.html.erb` completely.

Rename `app/assets/javascript/application.js.rb` to `app/assets/javascript/opal_application.rb`.

Rename the `app/assets/javascript` directory to `app/assets/opal`.

Edit `app/assets/config/manifest.js` and update `//= link_directory ../javascript .js` to `//= link_directory ../opal .js`:

```js
//= link_directory ../opal .js
```

Also, create `app/assets/config/manifest.opal.js` with:

```js
//= link_tree ../opal .js
//= link_directory ../opal .js
```

Edit `app/views/layouts/application.html.erb` and update:

```erb
<%= javascript_include_tag "application", "data-turbo-track": "reload" %>
```

to:

```erb
<%= javascript_include_tag "opal_application", "data-turbo-track": "reload" %>
```

Edit `app/assets/opal/opal_application.rb` and replace its content with code like the following (optionally including a `require` statement for one of the [samples](../../README.md#samples)):

```ruby
require 'glimmer-dsl-web' # brings opal and other dependencies automatically

# Add more require statements or Glimmer HTML DSL code
```

Example:

```ruby
require 'glimmer-dsl-web'

require 'glimmer-dsl-web/samples/hello/hello_world.rb'
```

If the `<body></body>` element is not available when the JS file is loading, put the code inside `Document.ready? do ... end`:

```ruby
require 'glimmer-dsl-web'

Document.ready? do
  require 'glimmer-dsl-web/samples/hello/hello_world.rb'
end
```

Example to confirm setup is working:

```ruby
require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  div {
    label(class: 'greeting') {
      'Hello, World!'
    }
  }
end
```

That produces:

```html
<body>
  <div data-parent="body" class="element element-1">
    <label class="greeting element element-2">
      Hello, World!
    </label>
  </div>
</body>
```

Start the Rails server:

```bash
bin/rails s
```

Visit `http://localhost:3000`

You should see:

![setup is working](/images/glimmer-dsl-web-setup-example-working.png)

If you want to customize where the top-level element is mounted, just pass a `parent: 'css_selector'` option.

HTML:

```html
...
<div id="app-container">
</div>
...
```

Glimmer HTML DSL Ruby code in the frontend:

```ruby
require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  div(parent: '#app-container') {
    label(class: 'greeting') {
      'Hello, World!'
    }
  }
end
```

That produces:

```html
...
<div id="app-container">
  <div data-parent="app-container" class="element element-1">
    <label class="greeting element element-2">
      Hello, World!
    </label>
  </div>
</div>
...
```

You may delete `opal_application.rb` after confirming that the setup works because `glimmer_component` is the recommended way for serious use of Glimmer DSL for Web in Rails web apps.

You may insert a Glimmer component anywhere into a Rails View using `glimmer_component(component_path, *args)` Rails helper. Add `include GlimmerHelper` to `ApplicationHelper` or another Rails helper, and use `<%= glimmer_component("path/to/component", *args) %>` in views.

To use `glimmer_component`, edit `app/helpers/application_helper.rb` in your Rails application, add `require 'glimmer/helpers/glimmer_helper'` on top and `include GlimmerHelper` inside the module.

`app/helpers/application_helper.rb` should look like this after the change:

```ruby
require 'glimmer/helpers/glimmer_helper'

module ApplicationHelper
  include GlimmerHelper
end
```

By default, elements are rendered in bulk for faster performance, meaning you cannot interact with element objects until rendering is done. This is a sensible default because most of the time there is no need to interact with elements until the full frontend application is fully rendered. That said, if it is preferred every once in a while to render elements piecemeal instead of in bulk, this behavior can be adjusted by passing the option `bulk_render: false` to the top-level component or top-level element (if there is no component).

Note that Turbo is disabled on Glimmer elements/components. You can still use Turbo/Hotwire side by side with Glimmer DSL for Web by using one of the two technologies in every page. But mixing them in the same page is not recommended at the moment, so any page loaded with Glimmer DSL for Web must be loaded without Turbo (for example by putting `data-turbo="false"` on links to Glimmer pages).

If you run into setup issues, refer to the sample project at https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails7-app in case some setup detail is clearer there.

Otherwise, if you still cannot setup successfully, please do not hesitate to report an issue at https://github.com/AndyObtiva/glimmer-dsl-web/issues or fix it and submit a pull request at https://github.com/AndyObtiva/glimmer-dsl-web/pulls.
