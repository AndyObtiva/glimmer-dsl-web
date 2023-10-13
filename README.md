# [<img src="https://raw.githubusercontent.com/AndyObtiva/glimmer/master/images/glimmer-logo-hi-res.png" height=85 />](https://github.com/AndyObtiva/glimmer) Glimmer DSL for Web 0.0.1
## Ruby in the Browser Web GUI Library
[![Gem Version](https://badge.fury.io/rb/glimmer-dsl-web.svg)](http://badge.fury.io/rb/glimmer-dsl-web)
[![Join the chat at https://gitter.im/AndyObtiva/glimmer](https://badges.gitter.im/AndyObtiva/glimmer.svg)](https://gitter.im/AndyObtiva/glimmer?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This project is inspired-by [Glimmer DSL for Opal](https://github.com/AndyObtiva/glimmer-dsl-opal) and is similar in enabling frontend GUI development with Ruby, but it mainly differs from Glimmer DSL for Opal by adopting a DSL that follows web-like HTML syntax in Ruby (enabling transfer of HTML/CSS/JS skills) instead of adopting a desktop GUI DSL that is webified. Also, it will begin by supporting [Opal Ruby](https://opalrb.com/), but it might grow to support [Ruby WASM](https://github.com/ruby/ruby.wasm) as an alternative to [Opal Ruby](https://opalrb.com/) that could be switched to with a simple configuration change.

### You can finally live in pure Rubyland on the web!

[Glimmer](https://github.com/AndyObtiva/glimmer) DSL for Web is an upcoming **pre-alpha** [gem](https://rubygems.org/gems/glimmer-dsl-web) that enables building web GUI in pure Ruby via [Opal](https://opalrb.com/) on [Rails](https://rubyonrails.org/) (and potentially [Ruby WASM](https://github.com/ruby/ruby.wasm) in the future).

**Hello, World! Sample**

Initial HTML Markup:

```html
<div id="app-container">
</div>
```

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

# This will hook into element #application and then build HTML inside it using Ruby DSL code
div(root: '#app-container') {
  label(class: 'greeting') {
    'Hello, World!'
  }
}
```

That produces:

```html
<div id="app-container">
  <div root="#app-container" id="element-1" class="element">
    <label class="greeting element" id="element-2">
      Hello, World!
    </label>
  </div>
</div>
```

**Hello, Button! Sample**

**UPCOMING (NOT RELEASED OR SUPPORTED YET)**

Glimmer GUI code demonstrating MVC + Glimmer Web Components (Views) + Data-Binding:

```ruby
require 'glimmer-dsl-web'

class Counter
  attr_accessor :count

  def initialize
    self.count = 0
  end

  def increment!
    self.count += 1
  end
end

class HelloButton
  include Glimmer::Web::Component
  
  before_render do
    @counter = Counter.new
  end
  
  markup {
    # This will hook into element #application and then build HTML inside it using Ruby DSL code
    div(root_css_selector) {
      text 'Hello, Button!'
      
      button {
        # Unidirectional Data-Binding indicating that on every change to @counter.count, the value
        # is read and converted to "Click To Increment: #{value}  ", and then automatically
        # copied to button innerText (content) to display to the user
        inner_text <= [@counter, :count, on_read: ->(value) { "Click To Increment: #{value}  " }]
        
        on_click {
          @counter.increment!
        }
      }
    }
  }
end

HelloButton.render('#application')
```

That produces:

```html
<div id="application">
  <button>
    Click To Increment: 0
  </button>
</div>
```

When clicked:

```html
<div id="application">
  <button>
    Click To Increment: 1
  </button>
</div>
```

When clicked 7 times:

```html
<div id="application">
  <button>
    Click To Increment: 7
  </button>
</div>
```



NOTE: Glimmer DSL for Web is a pre-alpha project. If you want it developed faster, please [open an issue report](https://github.com/AndyObtiva/glimmer-dsl-web/issues/new). I have completed some GitHub project features much faster before due to [issue reports](https://github.com/AndyObtiva/glimmer-dsl-web/issues) and [pull requests](https://github.com/AndyObtiva/glimmer-dsl-web/pulls). Please help make better by contributing, adopting for small or low risk projects, and providing feedback. It is still an early alpha, so the more feedback and issues you report the better.

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
      - [Hello, Button!](#hello-button)
  - [Glimmer Process](#glimmer-process)
  - [Help](#help)
    - [Issues](#issues)
    - [Chat](#chat)
  - [Feature Suggestions](#feature-suggestions)
  - [Change Log](#change-log)
  - [Contributing](#contributing)
  - [Contributors](#contributors)
  - [License](#license)

## Prerequisites

- Rails 6-7: [https://github.com/rails/rails](https://github.com/rails/rails)
- Opal 1.4.1 for Rails 6-7 or Opal 1.0.5 for Rails 5: [https://github.com/opal/opal](https://github.com/opal/opal)
- Opal-Rails 2.0.2 for Rails 6-7 or Opal-Rails 1.1.2 for Rails 5: [https://github.com/opal/opal-rails](https://github.com/opal/opal-rails)
- jQuery 3 (included): [https://code.jquery.com/](https://code.jquery.com/) (jQuery 3.6.0 is included in the [glimmer-dsl-web](https://rubygems.org/gems/glimmer-dsl-web) gem)

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

Initial HTML Markup:

```html
<div id="app-container">
</div>
```

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

# This will hook into element #application and then build HTML inside it using Ruby DSL code
div(root: '#app-container') {
  label(class: 'greeting') {
    'Hello, World!'
  }
}
```

That produces:

```html
<div id="app-container">
  <div root="#app-container" id="element-1" class="element">
    <label class="greeting element" id="element-2">
      Hello, World!
    </label>
  </div>
</div>
```

Start the Rails server:
```
rails s
```

Visit `http://localhost:3000`

You should see:

![setup is working](/images/glimmer-dsl-web-setup-example-working.png)

If you run into any issues in setup, refer to the [Sample Glimmer DSL for Web Rails 7 App](https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails7-app) project (in case I forgot to include some setup steps by mistake).

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

Initial HTML Markup:

```html
<div id="app-container">
</div>
```

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

# This will hook into element #application and then build HTML inside it using Ruby DSL code
div(root: '#app-container') {
  label(class: 'greeting') {
    'Hello, World!'
  }
}
```

That produces:

```html
<div id="app-container">
  <div root="#app-container" id="element-1" class="element">
    <label class="greeting element" id="element-2">
      Hello, World!
    </label>
  </div>
</div>
```

Start the Rails server:
```
rails s
```

Visit `http://localhost:3000`

You should see:

![setup is working](/images/glimmer-dsl-web-setup-example-working.png)

**NOT RELEASED OR SUPPORTED YET**

If you run into any issues in setup, refer to the [Sample Glimmer DSL for Web Rails 6 App](https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails6-app) project (in case I forgot to include some setup steps by mistake).

Otherwise, if you still cannot setup successfully (even with the help of the sample project, or if the sample project stops working), please do not hesitate to report an [Issue request](https://github.com/AndyObtiva/glimmer-dsl-web/issues) or fix and submit a [Pull Request](https://github.com/AndyObtiva/glimmer-dsl-web/pulls).

## Supported Glimmer DSL Keywords

All HTML elements.

All HTML attributes.

## Samples

This external sample app contains all the samples mentioned below configured inside a Rails [Opal](https://opalrb.com/) app with all the prerequisites ready to go for convenience:

https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails7-app

**[NOT RELEASED OR SUPPORTED YET]** https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails-app

### Hello Samples

#### Hello, World!

Initial HTML Markup:

```html
<div id="app-container">
</div>
```

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

# This will hook into element #application and then build HTML inside it using Ruby DSL code
div(root: '#application') {
  label(class: 'greeting') {
    'Hello, World!'
  }
}
```

That produces:

```html
<div id="app-container">
  <div root="#app-container" id="element-1" class="element">
    <label class="greeting element" id="element-2">
      Hello, World!
    </label>
  </div>
</div>
```

#### Hello, Button!

**UPCOMING (NOT RELEASED OR SUPPORTED YET)**

Glimmer GUI code demonstrating MVC + Glimmer Web Components (Views) + Data-Binding:

```ruby
require 'glimmer-dsl-web'

class Counter
  attr_accessor :count

  def initialize
    self.count = 0
  end

  def increment!
    self.count += 1
  end
end

class HelloButton
  include Glimmer::Web::Component
  
  before_render do
    @counter = Counter.new
  end
  
  markup {
    # This will hook into element #application and then build HTML inside it using Ruby DSL code
    div(root_css_selector) {
      text 'Hello, Button!'
      
      button {
        # Unidirectional Data-Binding indicating that on every change to @counter.count, the value
        # is read and converted to "Click To Increment: #{value}  ", and then automatically
        # copied to button innerText (content) to display to the user
        inner_text <= [@counter, :count, on_read: ->(value) { "Click To Increment: #{value}  " }]
        
        on_click {
          @counter.increment!
        }
      }
    }
  }
end

HelloButton.render('#application')
```

That produces:

```html
<div id="application">
  <button>
    Click To Increment: 0
  </button>
</div>
```

When clicked:

```html
<div id="application">
  <button>
    Click To Increment: 1
  </button>
</div>
```

When clicked 7 times:

```html
<div id="application">
  <button>
    Click To Increment: 7
  </button>
</div>
```

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

Copyright (c) 2023 - Andy Maleh.
See [LICENSE.txt](LICENSE.txt) for further details.

--

[<img src="https://raw.githubusercontent.com/AndyObtiva/glimmer/master/images/glimmer-logo-hi-res.png" height=40 />](https://github.com/AndyObtiva/glimmer) Built for [Glimmer](https://github.com/AndyObtiva/glimmer) (DSL Framework).
