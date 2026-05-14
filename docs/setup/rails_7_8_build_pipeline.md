# Rails 7/8 Setup (Build pipeline)

This is the modern Glimmer DSL for Web setup for Rails apps that use an explicit Opal build/watch flow instead of request-time Sprockets compilation.

The compiled JavaScript files can then be served by either Propshaft or Sprockets. In other words, the new pipeline changes how Opal assets are built, not which Rails asset server you must use.

It is the right guide for:

- Rails 8 apps (Propshaft by default)
- Rails 7 apps that you want on the same build/watch flow as Rails 8
- Rails 7 apps that still use Sprockets, as long as Sprockets only serves the compiled files from `app/assets/builds`

If you want the older Rails 7 + Sprockets/request-time pipeline, use [rails_7_sprockets_pipeline.md](rails_7_sprockets_pipeline.md) instead.

If you are migrating an older app from that legacy request-time pipeline to this build pipeline, read the `opal-rails` porting notes too: https://github.com/opal/opal-rails/blob/master/PORTING.md

At the time of writing, this flow depends on the current build-based `opal-rails` branch on the public `opal/opal-rails` repository. The older released `opal-rails ~> 2.0` line is the legacy Sprockets pipeline, not this build pipeline.

## Prerequisites

- Ruby 3.2+ if you want one Ruby version that works for both Rails 7 and Rails 8
- Rails 7 or Rails 8
- The host app may use either Propshaft or Sprockets to serve the compiled files from `app/assets/builds`

## 1. Install Rails

Install either Rails 8 or Rails 7:

```bash
gem install rails -v 8.1.3
```

or:

```bash
gem install rails -v 7.0.10
```

## 2. Create a new Rails app

For Rails 8:

```bash
rails _8.1.3_ new glimmer_app_server
```

For Rails 7 with the default Sprockets asset server:

```bash
rails _7.0.10_ new glimmer_app_server
```

For Rails 7 with Propshaft instead:

```bash
rails _7.0.10_ new glimmer_app_server -a propshaft
```

## 3. Add gems

Add the following to `Gemfile`:

```ruby
gem 'glimmer-dsl-web', '~> 0.9.2'
gem 'opal-rails', github: 'opal/opal-rails', branch: 'hmdne/drop-sprockets-and-modernize'
```

The explicit `opal-rails` entry overrides the older released Sprockets-era dependency with the current build-pipeline branch.

## 4. Bundle gems

```bash
bundle
```

If you upgrade `glimmer-dsl-web` or `opal-rails` later, clear the Opal cache before booting again:

```bash
rm -rf tmp/cache
```

## 5. Install the Opal build setup

Run:

```bash
bin/rails g opal:install
```

This creates the build-oriented Opal setup, including `config/initializers/opal.rb`, `app/assets/builds/.keep`, `Procfile.dev`, and `bin/dev`.

In fresh Sprockets apps, it also updates `app/assets/config/manifest.js` so Sprockets serves files from `app/assets/builds`.

## 6. Switch Opal to a `glimmer_component`-friendly layout

Edit `config/initializers/opal.rb` and add the following inside the `Rails.application.configure do ... end` block:

```ruby
  config.opal.source_path = Rails.root.join('app/assets/opal')
  config.opal.entrypoints_path = config.opal.source_path
  config.opal.entrypoints = :all
  config.opal.use_gems = %w[glimmer-dsl-web]
```

This tells `opal-rails` to compile each top-level file in `app/assets/opal` into a same-name asset in `app/assets/builds`, which matches how `glimmer_component('hello_world')` resolves assets.

Also remove the `javascript_include_tag "opal"` call that `bin/rails g opal:install` adds to `app/views/layouts/application.html.erb`. With this setup, `glimmer_component` includes the correct built asset for each component, so the global `opal` entrypoint should not stay in the layout.

You may delete the generated `app/opal` directory afterwards because this guide uses `app/assets/opal` instead.

## 7. Configure your asset server

If your app uses Propshaft, create `config/initializers/propshaft.rb` with:

```ruby
Rails.application.configure do
  config.assets.excluded_paths << Rails.root.join('app/assets/opal')
end
```

Without this, Propshaft may expose the raw `.rb` source files under `app/assets/opal` as public assets.

If your app uses Sprockets, make sure `app/assets/config/manifest.js` links the built outputs and does not link raw files from `app/assets/opal`:

```js
//= link_directory ../builds .js
//= link_directory ../builds .map
```

On a fresh app, `bin/rails g opal:install` already adds those `../builds` lines for you. This check matters most when porting an older Sprockets app that previously linked raw Opal sources.

## 8. Enable the Rails helper

Edit `app/helpers/application_helper.rb` so it looks like this:

```ruby
require 'glimmer/helpers/glimmer_helper'

module ApplicationHelper
  include GlimmerHelper
end
```

## 9. Generate a page to host the first component

Run:

```bash
bin/rails g scaffold welcome
bin/rails db:migrate
```

Edit `config/routes.rb` and add the root route inside `Rails.application.routes.draw do ... end`:

```ruby
root to: 'welcomes#index'
```

## 10. Render a Glimmer component from the view

Replace `app/views/welcomes/index.html.erb` with:

```erb
<%= glimmer_component('hello_world') %>
```

Now create `app/assets/opal/hello_world.rb`:

```ruby
require 'glimmer-dsl-web'

class HelloWorld
  include Glimmer::Web::Component

  markup do
    div do
      label(class: 'greeting') { 'Hello, World!' }
    end
  end
end
```

`glimmer_component('hello_world')` expects the top-level class to be named `HelloWorld`.

## 11. Start development mode

Run:

```bash
bin/dev
```

`bin/dev` starts both the Rails server and `bin/rails opal:watch`.

Visit the URL printed by Foreman, which is typically `http://127.0.0.1:5000`

You should see `Hello, World!`

Because this setup uses `glimmer_component`, you do not need `Document.ready?` in `hello_world.rb`. The helper inserts the built asset tag and mounts the component into the generated placeholder element for you.

## 12. Verify a production build

Run:

```bash
RAILS_ENV=production SECRET_KEY_BASE=dummy bin/rails assets:precompile
RAILS_ENV=production SECRET_KEY_BASE=dummy RAILS_SERVE_STATIC_FILES=1 bin/rails s
```

`assets:precompile` automatically runs `opal:build` first, so the built Glimmer assets are ready before Rails fingerprints and serves them.

Visit the URL printed by Rails again (by default `http://127.0.0.1:3000`) and confirm the page still renders.

## Notes

- For a larger app, put each top-level Glimmer component or entrypoint in its own file under `app/assets/opal`.
- `glimmer_component('contact_manager')` maps naturally to `app/assets/opal/contact_manager.rb` and the built asset `contact_manager.js`.
- The sample app at https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails7-app shows this layout in a more complete Rails application.
- This guide was manually validated in fresh Rails `8.1.3` Propshaft and Rails `7.0.10` Propshaft and Sprockets apps in both development and production modes.
- If you run into issues with an older app layout, check the current `opal-rails` migration notes at https://github.com/opal/opal-rails/blob/master/PORTING.md
