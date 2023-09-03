# [<img src="https://raw.githubusercontent.com/AndyObtiva/glimmer/master/images/glimmer-logo-hi-res.png" height=85 />](https://github.com/AndyObtiva/glimmer) Glimmer DSL for Web 0.0.1
## Ruby in the Browser Web GUI Library
[![Gem Version](https://badge.fury.io/rb/glimmer-dsl-web.svg)](http://badge.fury.io/rb/glimmer-dsl-web)
[![Join the chat at https://gitter.im/AndyObtiva/glimmer](https://badges.gitter.im/AndyObtiva/glimmer.svg)](https://gitter.im/AndyObtiva/glimmer?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### You can finally live in pure Rubyland on the web!

[Glimmer](https://github.com/AndyObtiva/glimmer) DSL for [Opal](https://opalrb.com/) is an **alpha** [gem](https://rubygems.org/gems/glimmer-dsl-web) that enables building web GUI in pure Ruby via [Opal](https://opalrb.com/) on [Rails](https://rubyonrails.org/) **(now comes with the new Shine data-binding syntax)**.

Use in one of two ways:
- **Direct:** build the GUI of web apps with the same friendly desktop GUI Ruby syntax as [Glimmer DSL for SWT](https://github.com/AndyObtiva/glimmer-dsl-swt), thus requiring a lot less code than web technologies that is in pure Ruby and avoiding opaque web concepts like 'render' and 'reactive'. No HTML/JS/CSS skills are even required. Web designers may be involved with CSS styling only if needed.
- **Adapter:** auto-webify [Glimmer](https://github.com/AndyObtiva/glimmer) desktop apps (i.e. apps built with [Glimmer DSL for SWT](https://github.com/AndyObtiva/glimmer-dsl-swt)) via [Opal](https://opalrb.com/) on [Rails](https://rubyonrails.org/) without changing a line of GUI code. Just insert them as a single require statement in a Rails app, and BOOM! They're running on the web! Apps may then optionally be custom-styled for the web by web designers with standard CSS if needed.

Glimmer DSL for Web successfully reuses the entire [Glimmer](https://github.com/AndyObtiva/glimmer) core DSL engine in [Opal Ruby](https://opalrb.com/) inside a web browser, and as such inherits the full range of Glimmer desktop [data-binding](https://github.com/AndyObtiva/glimmer#data-binding) capabilities for the web (including Shine syntax using `<=>` and `<=` for bidirectional [two-way] and unidirectional [one-way] data-binding respectively).

(note that auto-webification of desktop apps that involve multiple threads might involve extra changes to the code to utilize web async calls due to the async nature of transpiled JavaScript code)

#### Hello, World! Sample

Code: [lib/glimmer-dsl-web/samples/hello/hello_world.rb](lib/glimmer-dsl-web/samples/hello/hello_world.rb)

Glimmer GUI code from [glimmer-dsl-web/samples/hello/hello_world.rb](lib/glimmer-dsl-web/samples/hello/hello_world.rb):

```ruby
# ...
shell {
  grid_layout

  text 'Hello, Table!'
  background_image File.expand_path('hello_table/baseball_park.png', __dir__)
  image File.expand_path('hello_table/baseball_park.png', __dir__)

  label {
    layout_data :center, :center, true, false

    text 'BASEBALL PLAYOFF SCHEDULE'
    background :transparent if OS.windows?
    foreground rgb(94, 107, 103)
    font name: 'Optima', height: 38, style: :bold
  }

  combo(:read_only) {
    layout_data :center, :center, true, false
    selection <=> [BaseballGame, :playoff_type]
    font height: 14
  }

  table(:editable) { |table_proxy|
    layout_data :fill, :fill, true, true

    table_column {
      text 'Game Date'
      width 150
      sort_property :date # ensure sorting by real date value (not `game_date` string specified in items below)
      editor :date_drop_down, property: :date_time
    }
    table_column {
      text 'Game Time'
      width 150
      sort_property :time # ensure sorting by real time value (not `game_time` string specified in items below)
      editor :time, property: :date_time
    }
    table_column {
      text 'Ballpark'
      width 180
      editor :none
    }
    table_column {
      text 'Home Team'
      width 150
      editor :combo, :read_only # read_only is simply an SWT style passed to combo widget
    }
    table_column {
      text 'Away Team'
      width 150
      editor :combo, :read_only # read_only is simply an SWT style passed to combo widget
    }
    table_column {
      text 'Promotion'
      width 150
      # default text editor is used here
    }

    # Data-bind table items (rows) to a model collection property, specifying column properties ordering per nested model
    items <=> [BaseballGame, :schedule, column_attributes: [:game_date, :game_time, :ballpark, :home_team, :away_team, :promotion]]

    # Data-bind table selection
    selection <=> [BaseballGame, :selected_game]

    # Default initial sort property
    sort_property :date

    # Sort by these additional properties after handling sort by the column the user clicked
    additional_sort_properties :date, :time, :home_team, :away_team, :ballpark, :promotion

    menu {
      menu_item {
        text 'Book'

        on_widget_selected {
          book_selected_game
        }
      }
    }
  }

  button {
    text 'Book Selected Game'
    layout_data :center, :center, true, false
    font height: 14
    enabled <= [BaseballGame, :selected_game]

    on_widget_selected {
      book_selected_game
    }
  }
}
# ...
```

**Hello, World! Screenshot:**

![Glimmer DSL for Web Hello Table](images/glimmer-dsl-web-hello-table.png)

NOTE: Glimmer DSL for Web is an alpha project (only about 76% complete). If you want it developed faster, then [open an issue report](https://github.com/AndyObtiva/glimmer-dsl-web/issues/new). I have completed some GitHub project features much faster before due to [issue reports](https://github.com/AndyObtiva/glimmer-dsl-web/issues) and [pull requests](https://github.com/AndyObtiva/glimmer-dsl-web/pulls). Please help make better by contributing, adopting for small or low risk projects, and providing feedback. It is still an early alpha, so the more feedback and issues you report the better.

**Alpha Version** 0.0.1 only supports bare-minimum capabilities for the included [samples](https://github.com/AndyObtiva/glimmer-dsl-web#samples) (originally written for [glimmer-dsl-swt](https://github.com/AndyObtiva/glimmer-dsl-swt)).

Learn more about the differences between various [Glimmer](https://github.com/AndyObtiva/glimmer) DSLs by looking at:

**[Glimmer DSL Comparison Table](https://github.com/AndyObtiva/glimmer#glimmer-dsl-comparison-table)**.

## Table of Contents

- [Glimmer DSL for Web](#-glimmer-dsl-for-opal-alpha-pure-ruby-web-gui)
  - [Principles](#principles)
  - [Background](#background)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Supported Glimmer DSL Keywords](#supported-glimmer-dsl-keywords)
  - [Samples](#samples)
    - [Hello Samples](#hello-samples)
      - [Hello, World!](#hello-world)
  - [Glimmer Process](#glimmer-process)
  - [Help](#help)
    - [Issues](#issues)
    - [Chat](#chat)
  - [Feature Suggestions](#feature-suggestions)
  - [Change Log](#change-log)
  - [Contributing](#contributing)
  - [Contributors](#contributors)
  - [License](#license)

## Principles

- **Live purely in Rubyland via the Glimmer GUI DSL**, completely oblivious to web browser technologies, thanks to [Opal](https://opalrb.com/).
- **HTML is for creating documents not interactive applications**. As such, software engineers can avoid it and focus on creating web applications more productively with Glimmer DSL for Web in pure Ruby instead (just like they do in desktop development) while content creators and web designers can be the ones responsible for creating HTML documents for web content purposes only as HTML was originally intended. That way, Glimmer web GUI is used and embedded in web pages when providing users with applications while the rest of the web pages are maintained by non-engineers as pure HTML. This achieves a correct separation of responsibilities and better productivity and maintainability.
- **Approximate styles by developers via the Glimmer GUI DSL. Perfect styles by designers via pure CSS**. Developers can simply build GUI with approximate styling similar to desktop GUI and mockups without worrying about pixel-perfect aesthetics. Web designers can take styling further with pure CSS since every HTML element auto-generated by [Glimmer DSL for Web](https://rubygems.org/gems/glimmer-dsl-web) (using [Glimmer DSL for XML & HTML](https://rubygems.org/gems/glimmer-dsl-xml)) has a predictable ID and CSS class. This achieves a proper separation of responsibilities between developers and designers.
- **Web servers are used just like servers in traditional client/server architecture**, meaning they simply provide RMI services to enable centralizing some of the application logic and data in the cloud to make available everywhere and enable data-sharing with others.
- **Forget Routers!** [Glimmer DSL for Web](https://rubygems.org/gems/glimmer-dsl-web) supports auto-routing of custom shells (windows), which are opened as separate tabs in a web browser with automatically generated routes and bookmarkable URLs.
- **Images Are Local** Desktop apps typically display local images included in app files. When running a desktop app on the web, Glimmer DSL for Web automatically copies application images to the assets directory and exposes them as download links. Desktop image Ruby code that uses `File.expand_path` or `File.join` automatically detects available image web URLs and matches them to corresponding desktop image paths behind the scenes, so desktop app images show up on the web without any extra effort! ([Hello, Table!](#hello-table-sample) and [Hello, Label!](#hello-label-sample) are good examples of that) (note that this works in Rails 5 on Heroku, but does not work in Rails 6-7 on Heroku though it works outside of it in Rails 6-7)

## Background

The original idea behind Glimmer DSL for Web (which [later evolved](#principles)) was that you start by having a [Glimmer DSL for SWT](https://github.com/AndyObtiva/glimmer-dsl-swt) desktop app that communicates with a Rails API for any web/cloud concerns. The pure Ruby [Glimmer DSL for SWT](https://github.com/AndyObtiva/glimmer-dsl-swt) is very simple, so it is more productive to build GUI in it since it does not go through a server/client request/response cycle and can be iterated on locally with a much shorter feedback cycle. Once the GUI and the rest of the app is built. You simply embed it in a Rails app as a one line require statement, and BOOM, it just works on the web inside a web browser with the same server/client communication you had in the desktop app (I am working on adding minimal support for net/http in Opal so that desktop apps that use it continue to work in a web browser. Until then, just use [Opal-jQuery](https://github.com/opal/opal-jquery) http support). That way, you get two apps for one: desktop and web.

Part of the idea is that web browsers just render GUI widgets similar to those of a desktop app (after all a web browser is a desktop app), so whether you run your GUI on the desktop or on the web should just be a low-level concern, hopefully automated completely with Glimmer DSL for Web.

Last but not least, you would likely want some special branding on the web, so you can push that off to a web designer who would be more than happy to do the web graphic design and customize the look and feel with pure CSS (no need for programming with Ruby or JavaScript). This enables a clean separation of concerns and distribution of tasks among developers and designers, let alone saving effort on the web GUI by reusing the desktop GUI as a base right off the bat.

Alternatively, web developers may directly use [Glimmer DSL for Web](https://rubygems.org/gems/glimmer-dsl-web) to build the GUI of web apps since it is as simple as desktop development, thus requiring a lot less code that is in pure Ruby only (as demonstrated in examples below) and avoiding opaque web concepts like 'render' and 'reactive' due to treating GUI as persistent just like desktop apps do. No HTML/JS/CSS skills are even required. Still, web designers may be involved with CSS only if needed, thanks to the clean semantic markup [Glimmer DSL for Web](https://rubygems.org/gems/glimmer-dsl-web) automatically produces.

## Prerequisites

- Rails 5-7: [https://github.com/rails/rails](https://github.com/rails/rails)
- Opal 1.4.1 for Rails 6-7 or Opal 1.0.5 for Rails 5: [https://github.com/opal/opal](https://github.com/opal/opal)
- Opal-Rails 2.0.2 for Rails 6-7 or Opal-Rails 1.1.2 for Rails 5: [https://github.com/opal/opal-rails](https://github.com/opal/opal-rails)
- jQuery 3 (included): [https://code.jquery.com/](https://code.jquery.com/) (jQuery 3.6.0 is included in the [glimmer-dsl-web](https://rubygems.org/gems/glimmer-dsl-web) gem)
- jQuery-UI 1 (included): [https://code.jquery.com/](https://jqueryui.com/) (jQuery-UI 1.13.1 is included in the [glimmer-dsl-web](https://rubygems.org/gems/glimmer-dsl-web) gem)
- jQuery-UI Timepicker 0.3 (included): [https://code.jquery.com/](https://fgelinas.com/code/timepicker/) (jQuery-UI Timepicker 0.3.3 is included in the [glimmer-dsl-web](https://rubygems.org/gems/glimmer-dsl-web) gem)

## Setup

(NOTE: Keep in mind this is a very early experimental and incomplete **alpha**. If you run into issues, try to go back to a [previous revision](https://rubygems.org/gems/glimmer-dsl-web/versions). Also, there is a slight chance any issues you encounter are fixed in master or some other branch that you could check out instead)

The [glimmer-dsl-web](https://rubygems.org/gems/glimmer-dsl-web) gem is a [Rails Engine](https://guides.rubyonrails.org/engines.html) gem that includes assets.

### Rails 7

Please follow the following steps to setup.

Install a Rails 7 gem:

```
gem install rails -v7.0.1
```

Start a new Rails 7 app:

```
rails new glimmer_app_server
```

Add the following to `Gemfile`:

```
gem 'opal', '1.4.1'
gem 'opal-rails', '2.0.2'
gem 'opal-async', '~> 1.4.0'
gem 'opal-jquery', '~> 0.4.6'
gem 'glimmer-dsl-web', '~> 0.0.1'
gem 'glimmer-dsl-xml', '~> 1.3.1', require: false
gem 'glimmer-dsl-css', '~> 1.2.1', require: false
```

Run:

```
bundle
```

Follow [opal-rails](https://github.com/opal/opal-rails) instructions, basically running:

```
bin/rails g opal:install
```

Edit `config/initializers/assets.rb` and add the following at the bottom:
```
Opal.use_gem 'glimmer-dsl-web'
```

Run:

```
rails g scaffold welcome
```

Run:

```
rails db:migrate
```

Add the following to `config/routes.rb` inside the `Rails.application.routes.draw` block:

```ruby
mount Glimmer::Engine => "/glimmer" # add on top
root to: 'welcomes#index'
```

Edit `app/views/layouts/application.html.erb` and add the following below other `stylesheet_link_tag` declarations:

```erb
<%= stylesheet_link_tag    'glimmer/glimmer', media: 'all', 'data-turbolinks-track': 'reload' %>
```

Clear the file `app/views/welcomes/index.html.erb` completely from all content.

Delete `app/javascript/application.js`

Edit and replace `app/assets/javascript/application.js.rb` content with code below (optionally including a require statement for one of the [samples](#samples) below):

```ruby
require 'glimmer-dsl-web' # brings opal and other dependencies automatically

# Add more require-statements or Glimmer GUI DSL code
```

Example to confirm setup is working:

```ruby
require 'glimmer-dsl-web'

include Glimmer

shell {
  fill_layout
  text 'Example to confirm setup is working'
  
  label {
    text "Welcome to Glimmer DSL for Web!"
    foreground :red
    font height: 24
  }
}.open
```

Start the Rails server:
```
rails s
```

Visit `http://localhost:3000`

You should see:

![setup is working](/images/glimmer-dsl-web-setup-example-working.png)

If you run into any issues in setup, refer to the [Sample Glimmer DSL for Web Rails 7 App](https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails7-app) project (in case I forgot to include some setup steps by mistake). It is also hosted online (proving that it works): https://sample-glimmer-dsl-web-rails7.herokuapp.com/

Otherwise, if you still cannot setup successfully (even with the help of the sample project, or if the sample project stops working), please do not hesitate to report an [Issue request](https://github.com/AndyObtiva/glimmer-dsl-web/issues) or fix and submit a [Pull Request](https://github.com/AndyObtiva/glimmer-dsl-web/pulls).

### Rails 6

Please follow the following steps to setup.

Install a Rails 6 gem:

```
gem install rails -v6.1.4.6
```

Start a new Rails 6 app (skipping webpack):

```
rails new glimmer_app_server --skip-webpack-install
```

Disable the `webpacker` gem line in `Gemfile`:

```ruby
# gem 'webpacker', '~> 5.0'
```

Add the following to `Gemfile`:

```ruby
gem 'opal', '1.4.1'
gem 'opal-rails', '2.0.2'
gem 'opal-async', '~> 1.4.0'
gem 'opal-jquery', '~> 0.4.6'
gem 'glimmer-dsl-web', '~> 0.0.1'
gem 'glimmer-dsl-xml', '~> 1.3.1', require: false
gem 'glimmer-dsl-css', '~> 1.2.1', require: false
```

Run:

```
bundle
```

Follow [opal-rails](https://github.com/opal/opal-rails) instructions, basically running:

```
bin/rails g opal:install
```

Edit `config/initializers/assets.rb` and add the following at the bottom:
```
Opal.use_gem 'glimmer-dsl-web'
```

Run:

```
rails g scaffold welcome
```

Run:

```
rails db:migrate
```

Add the following to `config/routes.rb` inside the `Rails.application.routes.draw` block:

```ruby
mount Glimmer::Engine => "/glimmer" # add on top
root to: 'welcomes#index'
```

Edit `app/views/layouts/application.html.erb` and add the following below other `stylesheet_link_tag` declarations:

```erb
<%= stylesheet_link_tag 'glimmer/glimmer', media: 'all', 'data-turbolinks-track': 'reload' %>
```

Also, delete the following line:

```erb
<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
```

Clear the file `app/views/welcomes/index.html.erb` completely from all content.

Edit and replace `app/assets/javascript/application.js.rb` content with code below (optionally including a require statement for one of the [samples](#samples) below):

```ruby
require 'glimmer-dsl-web' # brings opal and other dependencies automatically

# Add more require-statements or Glimmer GUI DSL code
```

Example to confirm setup is working:

```ruby
require 'glimmer-dsl-web'

include Glimmer

shell {
  fill_layout
  text 'Example to confirm setup is working'
  
  label {
    text "Welcome to Glimmer DSL for Web!"
    foreground :red
    font height: 24
  }
}.open
```

Start the Rails server:
```
rails s
```

Visit `http://localhost:3000`

You should see:

![setup is working](/images/glimmer-dsl-web-setup-example-working.png)

If you run into any issues in setup, refer to the [Sample Glimmer DSL for Web Rails 6 App](https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails6-app) project (in case I forgot to include some setup steps by mistake). It is also hosted online (proving that it works): https://sample-glimmer-dsl-web-rails6.herokuapp.com/

Otherwise, if you still cannot setup successfully (even with the help of the sample project, or if the sample project stops working), please do not hesitate to report an [Issue request](https://github.com/AndyObtiva/glimmer-dsl-web/issues) or fix and submit a [Pull Request](https://github.com/AndyObtiva/glimmer-dsl-web/pulls).

## Supported Glimmer DSL Keywords

The following keywords from [glimmer-dsl-swt](https://github.com/AndyObtiva/glimmer-dsl-swt) have fully functional partial support in Opal:

Widgets:
- `arrow`: featured in [Hello, Arrow!](#hello-arrow)
- `button`: featured in [Hello, Checkbox!](#hello-checkbox) / [Hello, Button!](#hello-button) / [Hello, Table!](#hello-table) / [Hello, Radio Group!](#hello-radio-group) / [Hello, Radio!](#hello-radio) / [Hello, Message Box!](#hello-message-box) / [Hello, List Single Selection!](#hello-list-single-selection) / [Hello, List Multi Selection!](#hello-list-multi-selection) / [Hello, Group!](#hello-group) / [Hello, Combo!](#hello-combo) / [Hello, Checkbox Group!](#hello-checkbox-group) / [Contact Manager](#contact-manager) / [Tic Tac Toe](#tic-tac-toe) / [Login](#login)
- `browser`: featured in [Hello, Browser!](#hello-browser)
- `calendar`: featured in [Hello, Date Time!](#hello-date-time)
- `checkbox`: featured in [Hello, Checkbox Group!](#hello-checkbox-group) / [Hello, Checkbox!](#hello-checkbox)
- `checkbox_group`: featured in [Hello, Checkbox Group!](#hello-checkbox-group)
- `combo`: featured in [Hello, Table!](#hello-table) / [Hello, Combo!](#hello-combo)
- `composite`: featured in [Hello, Radio!](#hello-radio) / [Hello, Computed!](#hello-computed) / [Hello, Checkbox!](#hello-checkbox) / [Tic Tac Toe](#tic-tac-toe) / [Login](#login) / [Contact Manager](#contact-manager)
- `date`: featured in [Hello, Table!](#hello-table) / [Hello, Date Time!](#hello-date-time) / [Hello, Custom Shell!](#hello-custom-shell) / [Tic Tac Toe](#tic-tac-toe)
- `date_drop_down`: featured in [Hello, Table!](#hello-table) / [Hello, Date Time!](#hello-date-time)
- `dialog`: featured in [Hello, Dialog!](#hello-dialog)
- `group`: featured in [Hello, Group!](#hello-group) / [Contact Manager](#contact-manager)
- `label`: featured in [Hello, Computed!](#hello-computed) / [Hello, Checkbox Group!](#hello-checkbox-group) / [Hello, Checkbox!](#hello-checkbox) / [Hello, World!](#hello-world) / [Hello, Table!](#hello-table) / [Hello, Tab!](#hello-tab) / [Hello, Radio Group!](#hello-radio-group) / [Hello, Radio!](#hello-radio) / [Hello, Pop Up Context Menu!](#hello-pop-up-context-menu) / [Hello, Menu Bar!](#hello-menu-bar) / [Hello, Date Time!](#hello-date-time) / [Hello, Custom Widget!](#hello-custom-widget) / [Hello, Custom Shell!](#hello-custom-shell) / [Contact Manager](#contact-manager) / [Login](#login)
- `list` (w/ optional `:multi` SWT style): featured in [Hello, List Single Selection!](#hello-list-single-selection) / [Hello, List Multi Selection!](#hello-list-multi-selection) / [Contact Manager](#contact-manager)
- `menu`: featured in [Hello, Menu Bar!](#hello-menu-bar) / [Hello, Pop Up Context Menu!](#hello-pop-up-context-menu) / [Hello, Table!](#hello-table)
- `menu_bar`: featured in [Hello, Menu Bar!](#hello-menu-bar)
- `menu_item`: featured in [Hello, Table!](#hello-table) / [Hello, Pop Up Context Menu!](#hello-pop-up-context-menu) / [Hello, Menu Bar!](#hello-menu-bar)
- `message_box`: featured in [Hello, Table!](#hello-table) / [Hello, Pop Up Context Menu!](#hello-pop-up-context-menu) / [Hello, Message Box!](#hello-message-box) / [Hello, Menu Bar!](#hello-menu-bar)
- `radio`: featured in [Hello, Radio!](#hello-radio) / [Hello, Group!](#hello-group)
- `radio_group`: featured in [Hello, Radio Group!](#hello-radio-group)
- `scrolled_composite`
- `shell`: featured in [Hello, Checkbox!](#hello-checkbox) / [Hello, Button!](#hello-button) / [Hello, Table!](#hello-table) / [Hello, Tab!](#hello-tab) / [Hello, Radio Group!](#hello-radio-group) / [Hello, Radio!](#hello-radio) / [Hello, List Single Selection!](#hello-list-single-selection) / [Hello, List Multi Selection!](#hello-list-multi-selection) / [Hello, Group!](#hello-group) / [Hello, Date Time!](#hello-date-time) / [Hello, Custom Shell!](#hello-custom-shell) / [Hello, Computed!](#hello-computed) / [Hello, Combo!](#hello-combo) / [Hello, Checkbox Group!](#hello-checkbox-group) / [Contact Manager](#contact-manager) / [Tic Tac Toe](#tic-tac-toe) / [Login](#login)
- `tab_folder`: featured in [Hello, Tab!](#hello-tab)
- `tab_item`: featured in [Hello, Tab!](#hello-tab)
- `c_tab_folder`: featured in [Hello, C Tab!](#hello-c-tab)
- `c_tab_item`: featured in [Hello, C Tab!](#hello-c-tab)
- `table`: featured in [Hello, Custom Shell!](#hello-custom-shell) / [Hello, Table!](#hello-table) / [Contact Manager](#contact-manager)
- `table_column`: featured in [Hello, Table!](#hello-table) / [Hello, Custom Shell!](#hello-custom-shell) / [Contact Manager](#contact-manager)
- `text`: featured in [Hello, Computed!](#hello-computed) / [Login](#login) / [Contact Manager](#contact-manager)
- `time`: featured in [Hello, Table!](#hello-table) / [Hello, Date Time!](#hello-date-time)
- Glimmer::UI::CustomWidget: ability to define any keyword as a custom widget - featured in [Hello, Custom Widget!](#hello-custom-widget)
- Glimmer::UI::CustomShell: ability to define any keyword as a custom shell (aka custom window) that opens in a new browser window (tab) automatically unless there is no shell open in the current browser window (tab) - featured in [Hello, Custom Shell!](#hello-custom-shell)

Layouts:
- `grid_layout`: featured in [Hello, Custom Shell!](#hello-custom-shell) / [Hello, Computed!](#hello-computed) / [Hello, Table!](#hello-table) / [Hello, Pop Up Context Menu!](#hello-pop-up-context-menu) / [Hello, Menu Bar!](#hello-menu-bar) / [Hello, List Single Selection!](#hello-list-single-selection) / [Hello, List Multi Selection!](#hello-list-multi-selection) / [Contact Manager](#contact-manager) / [Login](#login) / [Tic Tac Toe](#tic-tac-toe)
- `row_layout`: featured in [Hello, Radio Group!](#hello-radio-group) / [Hello, Radio!](#hello-radio) / [Hello, Group!](#hello-group) / [Hello, Date Time!](#hello-date-time) / [Hello, Combo!](#hello-combo) / [Hello, Checkbox Group!](#hello-checkbox-group) / [Hello, Checkbox!](#hello-checkbox) / [Contact Manager](#contact-manager)
- `fill_layout`: featured in [Hello, Custom Widget!](#hello-custom-widget)
- `layout_data`: featured in [Hello, Table!](#hello-table) / [Hello, Custom Shell!](#hello-custom-shell) / [Hello, Computed!](#hello-computed) / [Tic Tac Toe](#tic-tac-toe) / [Contact Manager](#contact-manager)

Graphics/Style:
- `color`: featured in [Hello, Custom Widget!](#hello-custom-widget) / [Hello, Menu Bar!](#hello-menu-bar)
- `font`: featured in [Hello, Checkbox Group!](#hello-checkbox-group) / [Hello, Checkbox!](#hello-checkbox) / [Hello, Table!](#hello-table) / [Hello, Radio Group!](#hello-radio-group) / [Hello, Radio!](#hello-radio) / [Hello, Pop Up Context Menu!](#hello-pop-up-context-menu) / [Hello, Menu Bar!](#hello-menu-bar) / [Hello, Group!](#hello-group) / [Hello, Date Time!](#hello-date-time) / [Hello, Custom Widget!](#hello-custom-widget) / [Hello, Custom Shell!](#hello-custom-shell) / [Contact Manager](#contact-manager) / [Tic Tac Toe](#tic-tac-toe)
- `Point` class used in setting location on widgets
- `swt` and `SWT` class to set SWT styles on widgets - featured in [Hello, Custom Shell!](#hello-custom-shell) / [Login](#login) / [Contact Manager](#contact-manager)

Data-Binding/Observers:
- `bind`: featured in [Hello, Computed!](#hello-computed) / [Hello, Combo!](#hello-combo) / [Hello, Checkbox Group!](#hello-checkbox-group) / [Hello, Checkbox!](#hello-checkbox) / [Hello, Button!](#hello-button) / [Hello, Table!](#hello-table) / [Hello, Radio Group!](#hello-radio-group) / [Hello, Radio!](#hello-radio) / [Hello, List Single Selection!](#hello-list-single-selection) / [Hello, List Multi Selection!](#hello-list-multi-selection) / [Hello, Group!](#hello-group) / [Hello, Date Time!](#hello-date-time) / [Hello, Custom Widget!](#hello-custom-widget) / [Hello, Custom Shell!](#hello-custom-shell) / [Login](#login) / [Contact Manager](#contact-manager) / [Tic Tac Toe](#tic-tac-toe)
- `observe`: featured in [Hello, Table!](#hello-table) / [Tic Tac Toe](#tic-tac-toe)
- `on_widget_selected`: featured in [Hello, Combo!](#hello-combo) / [Hello, Checkbox Group!](#hello-checkbox-group) / [Hello, Checkbox!](#hello-checkbox) / [Hello, Button!](#hello-button) / [Hello, Table!](#hello-table) / [Hello, Radio Group!](#hello-radio-group) / [Hello, Radio!](#hello-radio) / [Hello, Pop Up Context Menu!](#hello-pop-up-context-menu) / [Hello, Message Box!](#hello-message-box) / [Hello, Menu Bar!](#hello-menu-bar) / [Hello, List Single Selection!](#hello-list-single-selection) / [Hello, List Multi Selection!](#hello-list-multi-selection) / [Hello, Group!](#hello-group) / [Contact Manager](#contact-manager) / [Login](#login) / [Tic Tac Toe](#tic-tac-toe)
- `on_modify_text`
- `on_key_pressed` (and SWT alias `on_swt_keydown`) - featured in [Login](#login) / [Contact Manager](#contact-manager)
- `on_key_released` (and SWT alias `on_swt_keyup`)
- `on_mouse_down` (and SWT alias `on_swt_mousedown`)
- `on_mouse_up` (and SWT alias `on_swt_mouseup`) - featured in [Hello, Custom Shell!](#hello-custom-shell) / [Contact Manager](#contact-manager)

Event loop:
- `display`: featured in [Tic Tac Toe](#tic-tac-toe)
- `async_exec`: featured in [Hello, Custom Widget!](#hello-custom-widget) / [Hello, Custom Shell!](#hello-custom-shell)

Canvas Shape DSL:
- `line`
- `point`
- `oval`
- `polygon`
- `polyline`
- `rectangle`
- `string`
- `text`

## Samples

Follow the instructions below to try out [glimmer-dsl-swt](https://github.com/AndyObtiva/glimmer-dsl-swt) samples webified via [glimmer-dsl-web](https://rubygems.org/gems/glimmer-dsl-web)

The [Hello samples](#hello-samples) demonstrate tiny building blocks (widgets) for building full fledged applications.

The [Elaborate samples](#elaborate-samples) demonstrate more advanced sample applications that assemble multiple building blocks.

This external sample app contains all the samples mentioned below configured inside a Rails [Opal](https://opalrb.com/) app with all the prerequisites ready to go for convenience:

https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails7-app

https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails-app

You may visit a Heroku hosted version at:

https://sample-glimmer-dsl-web-rails7.herokuapp.com/

https://sample-glimmer-dsl-web-app.herokuapp.com/

Note: Some of the screenshots might be out of date with updates done to samples in both [glimmer-dsl-swt](https://github.com/AndyObtiva/glimmer-dsl-swt) and [glimmer-dsl-web ](https://github.com/AndyObtiva/glimmer-dsl-web ).

### Hello Samples

#### Hello, World!

Add the following require statement to `app/assets/javascripts/application.rb`

```ruby
require 'glimmer-dsl-web /samples/hello/hello_world'
```

Or add the Glimmer code directly if you prefer to play around with it:

```ruby
include Glimmer
   
shell {
  text 'Glimmer'
  label {
    text 'Hello, World!'
  }
}.open
```

Glimmer app on the desktop (using [`glimmer-dsl-swt`](https://github.com/AndyObtiva/glimmer-dsl-swt) gem):

![Glimmer DSL for SWT Hello World](https://github.com/AndyObtiva/glimmer/blob/master/images/glimmer-hello-world.png)

Glimmer app on the web (using `glimmer-dsl-web ` gem):

Start the Rails server:
```
rails s
```

Visit `http://localhost:3000`

You should see "Hello, World!"

![Glimmer DSL for Web Hello World](images/glimmer-dsl-web -hello-world.png)

## Glimmer Supporting Libraries

Here is a list of notable 3rd party gems used by Glimmer DSL for Web:
- [glimmer-dsl-xml](https://github.com/AndyObtiva/glimmer-dsl-xml): Glimmer DSL for XML & HTML in pure Ruby.
- [glimmer-dsl-css](https://github.com/AndyObtiva/glimmer-dsl-css): Glimmer DSL for CSS (Cascading Style Sheets) in pure Ruby.
- [opal-async](https://github.com/AndyObtiva/opal-async): Non-blocking tasks and enumerators for Web.
- [to_collection](https://github.com/AndyObtiva/to_collection): Treat an array of objects and a singular object uniformly as a collection of objects.

## Glimmer Process

[Glimmer Process](https://github.com/AndyObtiva/glimmer/blob/master/PROCESS.md) is the lightweight software development process used for building Glimmer libraries and Glimmer apps, which goes beyond Agile, rendering all Agile processes obsolete. [Glimmer Process](https://github.com/AndyObtiva/glimmer/blob/master/PROCESS.md) is simply made up of 7 guidelines to pick and choose as necessary until software development needs are satisfied.

Learn more by reading the [GPG](https://github.com/AndyObtiva/glimmer/blob/master/PROCESS.md) (Glimmer Process Guidelines)

## Help

### Issues

You may submit [issues](https://github.com/AndyObtiva/glimmer-dsl-web /issues) on [GitHub](https://github.com/AndyObtiva/glimmer-dsl-web /issues).

[Click here to submit an issue.](https://github.com/AndyObtiva/glimmer-dsl-web /issues)

### Chat

If you need live help, try to [![Join the chat at https://gitter.im/AndyObtiva/glimmer](https://badges.gitter.im/AndyObtiva/glimmer.svg)](https://gitter.im/AndyObtiva/glimmer?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Feature Suggestions

These features have been suggested. You might see them in a future version of Glimmer. You are welcome to contribute more feature suggestions.

[TODO.md](TODO.md)

## Change Log

[CHANGELOG.md](CHANGELOG.md)

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md)

## Contributors

* [Andy Maleh](https://github.com/AndyObtiva) (Founder)

[Click here to view contributor commits.](https://github.com/AndyObtiva/glimmer-dsl-web /graphs/contributors)

## License

[MIT](https://opensource.org/licenses/MIT)

Copyright (c) 2020-2022 - Andy Maleh.
See [LICENSE.txt](LICENSE.txt) for further details.

--

[<img src="https://raw.githubusercontent.com/AndyObtiva/glimmer/master/images/glimmer-logo-hi-res.png" height=40 />](https://github.com/AndyObtiva/glimmer) Built for [Glimmer](https://github.com/AndyObtiva/glimmer) (DSL Framework).
