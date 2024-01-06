# [<img src="https://raw.githubusercontent.com/AndyObtiva/glimmer/master/images/glimmer-logo-hi-res.png" height=85 />](https://github.com/AndyObtiva/glimmer) Glimmer DSL for Web 0.0.11 (Early Alpha)
## Ruby in the Browser Web GUI Frontend Library
[![Gem Version](https://badge.fury.io/rb/glimmer-dsl-web.svg)](http://badge.fury.io/rb/glimmer-dsl-web)
[![Join the chat at https://gitter.im/AndyObtiva/glimmer](https://badges.gitter.im/AndyObtiva/glimmer.svg)](https://gitter.im/AndyObtiva/glimmer?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[Glimmer](https://github.com/AndyObtiva/glimmer) DSL for Web enables building Web GUI frontends using [Ruby in the Browser](https://www.youtube.com/watch?v=4AdcfbI6A4c), as per [Matz's recommendation in his RubyConf 2022 keynote speech to replace JavaScript with Ruby](https://youtu.be/knutsgHTrfQ?t=789). It aims at providing the simplest, most intuitive, most straight-forward, and most productive frontend library in existence. The library follows the Ruby way (with [DSLs](https://martinfowler.com/books/dsl.html) and [TIMTOWTDI](https://en.wiktionary.org/wiki/TMTOWTDI#English)) and the Rails way ([Convention over Configuration](https://rubyonrails.org/doctrine)) while supporting both Unidirectional (One-Way) [Data-Binding](#hello-data-binding) (using `<=`) and Bidirectional (Two-Way) [Data-Binding](#hello-data-binding) (using `<=>`). Dynamic rendering (and re-rendering) of HTML content is also supported via [Content Data-Binding](#hello-content-data-binding). And, modular design is supported with [Glimmer Web Components](#hello-component). You can finally live in pure Rubyland on the Web in both the frontend and backend with [Glimmer DSL for Web](https://rubygems.org/gems/glimmer-dsl-web)!

**Hello, World! Sample**

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  div {
    'Hello, World!'
  }.render
end
```

That produces the following under `<body></body>`:

```html
<div data-parent="body" class="element element-1">
  Hello, World!
</div>
```

![setup is working](/images/glimmer-dsl-web-setup-example-working.png)

**Hello, Button!**

Event listeners can be setup on any element using the same event names used in HTML (e.g. `onclick`) while passing in a standard Ruby block to handle behavior. `$$` gives access to `window` to invoke functions like `alert`.

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  div {
    button('Greet') {
      onclick do
        $$.alert('Hello, Button!')
      end
    }
  }.render
end
```

That produces the following under `<body></body>`:

```html
<div data-parent="body" class="element element-1">
  <button class="element element-2">Greet</button>
</div>
```

Screenshot:

![Hello, Button!](/images/glimmer-dsl-web-samples-hello-hello-button.gif)

**Hello, Form!**

[Glimmer DSL for Web](https://rubygems.org/gems/glimmer-dsl-web) gives access to all Web Browser built-in features like HTML form validations, input focus, events, and element functions from a very terse and productive Ruby GUI DSL.

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  div {
    h1('Contact Form')
    
    form {
      div {
        label('Name: ', for: 'name-field')
        @name_input = input(type: 'text', id: 'name-field', required: true, autofocus: true)
      }
      
      div {
        label('Email: ', for: 'email-field')
        @email_input = input(type: 'email', id: 'email-field', required: true)
      }
      
      div {
        input(type: 'submit', value: 'Add Contact') {
          onclick do |event|
            if ([@name_input, @email_input].all? {|input| input.check_validity })
              # re-open table content and add row
              @table.content {
                tr {
                  td { @name_input.value }
                  td { @email_input.value }
                }
              }
              @email_input.value = @name_input.value = ''
              @name_input.focus
            end
          end
        }
      }
    }
    
    h1('Contacts Table')
    
    @table = table {
      tr {
        th('Name')
        th('Email')
      }
      
      tr {
        td('John Doe')
        td('johndoe@example.com')
      }
      
      tr {
        td('Jane Doe')
        td('janedoe@example.com')
      }
    }
    
    # CSS Styles
    style {
      <<~CSS
        input {
          margin: 5px;
        }
        input[type=submit] {
          margin: 5px 0;
        }
        table {
          border:1px solid grey;
          border-spacing: 0;
        }
        table tr td, table tr th {
          padding: 5px;
        }
        table tr:nth-child(even) {
          background: #ccc;
        }
      CSS
    }
  }.render
end
```

That produces the following under `<body></body>`:

```html
<div data-parent="body" class="element element-1">
  <h1 class="element element-2">Contact Form</h1>
  
  <form class="element element-3">
    <div class="element element-4">
      <label for="name-field" class="element element-5">Name: </label>
      <input type="text" id="name-field" required="true" autofocus="true" class="element element-6">
    </div>
    
    <div class="element element-7">
      <label for="email-field" class="element element-8">Email: </label>
      <input type="email" id="email-field" required="true" class="element element-9">
    </div>
    
    <div class="element element-10">
      <input type="submit" value="Add Contact" class="element element-11">
    </div>
  </form>
  
  <h1 class="element element-12">Contacts Table</h1>
  
  <table class="element element-13">
    <tr class="element element-14">
      <th class="element element-15">Name</th>
      <th class="element element-16">Email</th>
    </tr>
    
    <tr class="element element-17">
      <td class="element element-18">John Doe</td>
      <td class="element element-19">johndoe@example.com</td>
    </tr>
    
    <tr class="element element-20">
      <td class="element element-21">Jane Doe</td>
      <td class="element element-22">janedoe@example.com</td>
    </tr>
  </table>
  
  <style class="element element-23">
    input {
      margin: 5px;
    }
    input[type=submit] {
      margin: 5px 0;
    }
    table {
      border:1px solid grey;
      border-spacing: 0;
    }
    table tr td, table tr th {
      padding: 5px;
    }
    table tr:nth-child(even) {
      background: #ccc;
    }
  </style>
</div>
```

Screenshot:

![Hello, Form!](/images/glimmer-dsl-web-samples-hello-hello-form.gif)

**Hello, Data-Binding!**

[Glimmer DSL for Web](https://rubygems.org/gems/glimmer-dsl-web) intuitively supports both Unidirectional (One-Way) Data-Binding via the `<=` operator and Bidirectional (Two-Way) Data-Binding via the `<=>` operator, incredibly simplifying how to sync View properties with Model attributes with the simplest code to reason about.

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

Address = Struct.new(:street, :street2, :city, :state, :zip_code, keyword_init: true) do
  STATES = {...} # contains US States
  
  def state_code
    STATES.invert[state]
  end
  
  def state_code=(value)
    self.state = STATES[value]
  end

  def summary
    string_attributes = to_h.except(:billing_and_shipping)
    summary = string_attributes.values.map(&:to_s).reject(&:empty?).join(', ')
    summary += " (Billing & Shipping)" if billing_and_shipping
    summary
  end
end

@address = Address.new(
  street: '123 Main St',
  street2: 'Apartment 3C, 2nd door to the right',
  city: 'San Diego',
  state: 'California',
  zip_code: '91911',
  billing_and_shipping: true,
)

include Glimmer

Document.ready? do
  div {
    div(style: 'display: grid; grid-auto-columns: 80px 260px;') { |address_div|
      label('Street: ', for: 'street-field')
      input(id: 'street-field') {
        # Bidirectional Data-Binding with <=> ensures input.value and @address.street
        # automatically stay in sync when either side changes
        value <=> [@address, :street]
      }
      
      label('Street 2: ', for: 'street2-field')
      textarea(id: 'street2-field') {
        value <=> [@address, :street2]
      }
      
      label('City: ', for: 'city-field')
      input(id: 'city-field') {
        value <=> [@address, :city]
      }
      
      label('State: ', for: 'state-field')
      select(id: 'state-field') {
        Address::STATES.each do |state_code, state|
          option(value: state_code) { state }
        end
        
        value <=> [@address, :state_code]
      }
      
      label('Zip Code: ', for: 'zip-code-field')
      input(id: 'zip-code-field', type: 'number', min: '0', max: '99999') {
        # Bidirectional Data-Binding with <=> ensures input.value and @address.zip_code
        # automatically stay in sync when either side changes
        # on_write option specifies :to_s method to invoke on value before writing to model attribute
        # to ensure the numeric zip code value is stored as a String
        value <=> [@address, :zip_code,
                    on_write: :to_s,
                  ]
      }
      
      div(style: 'grid-column: 1 / span 2') {
        input(id: 'billing-and-shipping-field', type: 'checkbox') {
          checked <=> [@address, :billing_and_shipping]
        }
        label(for: 'billing-and-shipping-field') {
          'Use this address for both Billing & Shipping'
        }
      }
      
      style {
        <<~CSS
          #{address_div.selector} * {
            margin: 5px;
          }
          #{address_div.selector} input, #{address_div.selector} select {
            grid-column: 2;
          }
        CSS
      }
    }
  
    div(style: 'margin: 5px') {
      # Unidirectional Data-Binding is done with <= to ensure @address.summary changes
      # automatically update div.inner_text
      # (computed by changes to address attributes, meaning if street changes,
      # @address.summary is automatically recomputed.)
      inner_text <= [@address, :summary,
                      computed_by: @address.members + ['state_code'],
                    ]
    }
  }.render
end
```

Screenshot:

![Hello, Data-Binding!](/images/glimmer-dsl-web-samples-hello-hello-data-binding.gif)

**Hello, Content Data-Binding!**

If you need to regenerate HTML element content dynamically, you can use Content Data-Binding to effortlessly
rebuild HTML elements based on changes in a Model attribute that provides the source data.
In this example, we generate multiple address forms based on the number of addresses the user has.

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

class Address
  attr_accessor :text
  attr_reader :name, :street, :city, :state, :zip
  
  def name=(value)
    @name = value
    update_text
  end
  
  def street=(value)
    @street = value
    update_text
  end
  
  def city=(value)
    @city = value
    update_text
  end
  
  def state=(value)
    @state = value
    update_text
  end
  
  def zip=(value)
    @zip = value
    update_text
  end
  
  private
  
  def update_text
    self.text = [name, street, city, state, zip].compact.reject(&:empty?).join(', ')
  end
end

class User
  attr_accessor :addresses
  attr_reader :address_count
  
  def initialize
    @address_count = 1
    @addresses = []
    update_addresses
  end
  
  def address_count=(value)
    value = [[1, value.to_i].max, 3].min
    @address_count = value
    update_addresses
  end
  
  private
  
  def update_addresses
    address_count_change = address_count - addresses.size
    if address_count_change > 0
      address_count_change.times { addresses << Address.new }
    else
      address_count_change.abs.times { addresses.pop }
    end
  end
end

@user = User.new

include Glimmer

Document.ready? do
  div {
    div {
      label('Number of addresses: ', for: 'address-count-field')
      input(id: 'address-count-field', type: 'number', min: 1, max: 3) {
        value <=> [@user, :address_count]
      }
    }
    
    div {
      # Content Data-Binding is used to dynamically (re)generate content of div
      # based on changes to @user.addresses, replacing older content on every change
      content(@user, :addresses) do
        @user.addresses.each do |address|
          div {
            div(style: 'display: grid; grid-auto-columns: 80px 280px;') { |address_div|
              [:name, :street, :city, :state, :zip].each do |attribute|
                label(attribute.to_s.capitalize, for: "#{attribute}-field")
                input(id: "#{attribute}-field", type: 'text') {
                  value <=> [address, attribute]
                }
              end
              
              div(style: 'grid-column: 1 / span 2;') {
                inner_text <= [address, :text]
              }
              
              style {
                <<~CSS
                  #{address_div.selector} {
                    margin: 10px 0;
                  }
                  #{address_div.selector} * {
                    margin: 5px;
                  }
                  #{address_div.selector} label {
                    grid-column: 1;
                  }
                  #{address_div.selector} input, #{address_div.selector} select {
                    grid-column: 2;
                  }
                CSS
              }
            }
          }
        end
      end
    }
  }.render
end
```

Screenshot:

![Hello, Content Data-Binding!](/images/glimmer-dsl-web-samples-hello-hello-content-data-binding.gif)

**Hello, Component!**

You can define Glimmer web components (View components) to reuse visual concepts to your heart's content,
by simply defining a class with `include Glimmer::Web::Component` and encasing the reusable markup inside
a `markup {...}` block. Glimmer web components automatically extend the Glimmer GUI DSL with new keywords
that match the underscored versions of the component class names (e.g. a `OrderSummary` class yields
the `order_summary` keyword for reusing that component within the Glimmer GUI DSL).
Below, we define an `AddressForm` component that generates a `address_form` keyword, and then we
reuse it twice inside an `AddressPage` component displaying a Shipping Address and a Billing Address.

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

Address = Struct.new(:full_name, :street, :street2, :city, :state, :zip_code, keyword_init: true) do
  STATES = {
    "AK"=>"Alaska",
    "AL"=>"Alabama",
    "AR"=>"Arkansas",
    "AS"=>"American Samoa",
    "AZ"=>"Arizona",
    "CA"=>"California",
    "CO"=>"Colorado",
    "CT"=>"Connecticut",
    "DC"=>"District of Columbia",
    "DE"=>"Delaware",
    "FL"=>"Florida",
    "GA"=>"Georgia",
    "GU"=>"Guam",
    "HI"=>"Hawaii",
    "IA"=>"Iowa",
    "ID"=>"Idaho",
    "IL"=>"Illinois",
    "IN"=>"Indiana",
    "KS"=>"Kansas",
    "KY"=>"Kentucky",
    "LA"=>"Louisiana",
    "MA"=>"Massachusetts",
    "MD"=>"Maryland",
    "ME"=>"Maine",
    "MI"=>"Michigan",
    "MN"=>"Minnesota",
    "MO"=>"Missouri",
    "MS"=>"Mississippi",
    "MT"=>"Montana",
    "NC"=>"North Carolina",
    "ND"=>"North Dakota",
    "NE"=>"Nebraska",
    "NH"=>"New Hampshire",
    "NJ"=>"New Jersey",
    "NM"=>"New Mexico",
    "NV"=>"Nevada",
    "NY"=>"New York",
    "OH"=>"Ohio",
    "OK"=>"Oklahoma",
    "OR"=>"Oregon",
    "PA"=>"Pennsylvania",
    "PR"=>"Puerto Rico",
    "RI"=>"Rhode Island",
    "SC"=>"South Carolina",
    "SD"=>"South Dakota",
    "TN"=>"Tennessee",
    "TX"=>"Texas",
    "UT"=>"Utah",
    "VA"=>"Virginia",
    "VI"=>"Virgin Islands",
    "VT"=>"Vermont",
    "WA"=>"Washington",
    "WI"=>"Wisconsin",
    "WV"=>"West Virginia",
    "WY"=>"Wyoming"
  }
  
  def state_code
    STATES.invert[state]
  end
  
  def state_code=(value)
    self.state = STATES[value]
  end

  def summary
    to_h.values.map(&:to_s).reject(&:empty?).join(', ')
  end
end

# AddressForm Glimmer Web Component (View component)
#
# Including Glimmer::Web::Component makes this class a View component and automatically
# generates a new Glimmer GUI DSL keyword that matches the lowercase underscored version
# of the name of the class. AddressForm generates address_form keyword, which can be used
# elsewhere in Glimmer GUI DSL code as done inside AddressPage below.
class AddressForm
  include Glimmer::Web::Component
  
  option :address
  
  # Optionally, you can execute code before rendering markup.
  # This is useful for pre-setup of variables (e.g. Models) that you would use in the markup.
  #
  # before_render do
  # end
  
  # Optionally, you can execute code after rendering markup.
  # This is useful for post-setup of extra Model listeners that would interact with the
  # markup elements and expect them to be rendered already.
  #
  # after_render do
  # end
  
  # markup block provides the content of the
  markup {
    div {
      div(style: 'display: grid; grid-auto-columns: 80px 260px;') { |address_div|
        label('Full Name: ', for: 'full-name-field')
        input(id: 'full-name-field') {
          value <=> [address, :full_name]
        }
        
        @somelabel = label('Street: ', for: 'street-field')
        input(id: 'street-field') {
          value <=> [address, :street]
        }
        
        label('Street 2: ', for: 'street2-field')
        textarea(id: 'street2-field') {
          value <=> [address, :street2]
        }
        
        label('City: ', for: 'city-field')
        input(id: 'city-field') {
          value <=> [address, :city]
        }
        
        label('State: ', for: 'state-field')
        select(id: 'state-field') {
          Address::STATES.each do |state_code, state|
            option(value: state_code) { state }
          end

          value <=> [address, :state_code]
        }
        
        label('Zip Code: ', for: 'zip-code-field')
        input(id: 'zip-code-field', type: 'number', min: '0', max: '99999') {
          value <=> [address, :zip_code,
                      on_write: :to_s,
                    ]
        }
        
        style {
          <<~CSS
            #{address_div.selector} * {
              margin: 5px;
            }
            #{address_div.selector} input, #{address_div.selector} select {
              grid-column: 2;
            }
          CSS
        }
      }
      
      div(style: 'margin: 5px') {
        inner_text <= [address, :summary,
                        computed_by: address.members + ['state_code'],
                      ]
      }
    }
  }
end

# AddressPage Glimmer Web Component (View component)
#
# This View component represents the main page being rendered,
# as done by its `render` class method below
class AddressPage
  include Glimmer::Web::Component
  
  before_render do
    @shipping_address = Address.new(
      full_name: 'Johnny Doe',
      street: '3922 Park Ave',
      street2: 'PO BOX 8382',
      city: 'San Diego',
      state: 'California',
      zip_code: '91913',
    )
    @billing_address = Address.new(
      full_name: 'John C Doe',
      street: '123 Main St',
      street2: 'Apartment 3C',
      city: 'San Diego',
      state: 'California',
      zip_code: '91911',
    )
  end
  
  markup {
    div {
      h1('Shipping Address')
      
      address_form(address: @shipping_address)
      
      h1('Billing Address')
      
      address_form(address: @billing_address)
    }
  }
end

Document.ready? do
  # renders a top-level (root) AddressPage component
  AddressPage.render
end
```

Screenshot:

![Hello, Component!](/images/glimmer-dsl-web-samples-hello-hello-component.png)

**Hello, glimmer_component Rails Helper!**

You may insert a Glimmer component anywhere into a Rails View using
`glimmer_component(component_path, *args)` Rails helper. Add `include GlimmerHelper` to `ApplicationHelper`
or another Rails helper, and use `<%= glimmer_component("path/to/component", *args) %>` in Views.

Rails `ApplicationHelper` setup code:

```ruby
require 'glimmer/helpers/glimmer_helper'

module ApplicationHelper
  # ...
  include GlimmerHelper
  # ...
end
```

Rails View code:

```erb
<div id="address-container">
  <h1>Shipping Address </h1>
  <legend>Please enter your shipping address information (Zip Code must be a valid 5 digit number)</legend>
  <!-- This sample demonstrates use of glimmer_component helper with arguments -->
  <%= glimmer_component('address_form',
        full_name: params[:full_name],
        street: params[:street],
        street2: params[:street2],
        city: params[:city],
        state: params[:state],
        zip_code: params[:zip_code]
      )
   %>
   <div>
     <a href="/">&lt;&lt; Back Home</a>
   </div>
</div>
```

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

class AddressForm
  Address = Struct.new(:full_name, :street, :street2, :city, :state, :zip_code, keyword_init: true) do
    def state_code
      STATES.invert[state]
    end
    
    def state_code=(value)
      self.state = STATES[value]
    end
  
    def summary
      to_h.values.map(&:to_s).reject(&:empty?).join(', ')
    end
  end
  
  STATES = {
    "AK"=>"Alaska",
    "AL"=>"Alabama",
    "AR"=>"Arkansas",
    "AS"=>"American Samoa",
    "AZ"=>"Arizona",
    "CA"=>"California",
    "CO"=>"Colorado",
    "CT"=>"Connecticut",
    "DC"=>"District of Columbia",
    "DE"=>"Delaware",
    "FL"=>"Florida",
    "GA"=>"Georgia",
    "GU"=>"Guam",
    "HI"=>"Hawaii",
    "IA"=>"Iowa",
    "ID"=>"Idaho",
    "IL"=>"Illinois",
    "IN"=>"Indiana",
    "KS"=>"Kansas",
    "KY"=>"Kentucky",
    "LA"=>"Louisiana",
    "MA"=>"Massachusetts",
    "MD"=>"Maryland",
    "ME"=>"Maine",
    "MI"=>"Michigan",
    "MN"=>"Minnesota",
    "MO"=>"Missouri",
    "MS"=>"Mississippi",
    "MT"=>"Montana",
    "NC"=>"North Carolina",
    "ND"=>"North Dakota",
    "NE"=>"Nebraska",
    "NH"=>"New Hampshire",
    "NJ"=>"New Jersey",
    "NM"=>"New Mexico",
    "NV"=>"Nevada",
    "NY"=>"New York",
    "OH"=>"Ohio",
    "OK"=>"Oklahoma",
    "OR"=>"Oregon",
    "PA"=>"Pennsylvania",
    "PR"=>"Puerto Rico",
    "RI"=>"Rhode Island",
    "SC"=>"South Carolina",
    "SD"=>"South Dakota",
    "TN"=>"Tennessee",
    "TX"=>"Texas",
    "UT"=>"Utah",
    "VA"=>"Virginia",
    "VI"=>"Virgin Islands",
    "VT"=>"Vermont",
    "WA"=>"Washington",
    "WI"=>"Wisconsin",
    "WV"=>"West Virginia",
    "WY"=>"Wyoming"
  }

  include Glimmer::Web::Component
  
  option :full_name
  option :street
  option :street2
  option :city
  option :state
  option :zip_code
  
  attr_reader :address
  
  before_render do
    @address = Address.new(
      full_name: full_name,
      street: street,
      street2: street2,
      city: city,
      state: state,
      zip_code: zip_code,
    )
  end
  
  markup {
    div {
      div(style: 'display: grid; grid-auto-columns: 80px 260px;') { |address_div|
        label('Full Name: ', for: 'full-name-field')
        input(id: 'full-name-field') {
          value <=> [address, :full_name]
        }
        
        @somelabel = label('Street: ', for: 'street-field')
        input(id: 'street-field') {
          value <=> [address, :street]
        }
        
        label('Street 2: ', for: 'street2-field')
        textarea(id: 'street2-field') {
          value <=> [address, :street2]
        }
        
        label('City: ', for: 'city-field')
        input(id: 'city-field') {
          value <=> [address, :city]
        }
        
        label('State: ', for: 'state-field')
        select(id: 'state-field') {
          STATES.each do |state_code, state|
            option(value: state_code) { state }
          end

          value <=> [address, :state_code]
        }
        
        label('Zip Code: ', for: 'zip-code-field')
        input(id: 'zip-code-field', type: 'number', min: '0', max: '99999') {
          value <=> [address, :zip_code,
                      on_write: :to_s,
                    ]
        }
        
        style {
          <<~CSS
            #{address_div.selector} * {
              margin: 5px;
            }
            #{address_div.selector} input, #{address_div.selector} select {
              grid-column: 2;
            }
          CSS
        }
      }
      
      div(style: 'margin: 5px') {
        inner_text <= [address, :summary,
                        computed_by: address.members + ['state_code'],
                      ]
      }
    }
  }
end
```

Screenshot:

![Hello, glimmer_component Rails Helper!](/images/glimmer-dsl-web-samples-hello-hello-component.png)

NOTE: Glimmer DSL for Web is an Early Alpha project. If you want it developed faster, please [open an issue report](https://github.com/AndyObtiva/glimmer-dsl-web/issues/new). I have completed some GitHub project features much faster before due to [issue reports](https://github.com/AndyObtiva/glimmer-dsl-web/issues) and [pull requests](https://github.com/AndyObtiva/glimmer-dsl-web/pulls). Please help make better by contributing, adopting for small or low risk projects, and providing feedback. It is still an early alpha, so the more feedback and issues you report the better.

Learn more about the differences between various [Glimmer](https://github.com/AndyObtiva/glimmer) DSLs by looking at:

**[Glimmer DSL Comparison Table](https://github.com/AndyObtiva/glimmer#glimmer-dsl-comparison-table)**.

## Table of Contents

- [Glimmer DSL for Web](#-glimmer-dsl-for-opal-alpha-pure-ruby-web-gui)
  - [Principles](#principles)
  - [Background](#background)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Usage](#usage)
  - [Supported Glimmer DSL Keywords](#supported-glimmer-dsl-keywords)
  - [Coming from Glimmer DSL for Opal](#coming-from-glimmer-dsl-for-opal)
  - [Samples](#samples)
    - [Hello Samples](#hello-samples)
      - [Hello, World!](#hello-world)
      - [Hello, Button!](#hello-button)
      - [Hello, Form!](#hello-form)
      - [Hello, Data-Binding!](#hello-data-binding)
      - [Hello, Content Data-Binding!](#hello-content-data-binding)
      - [Hello, Component!](#hello-content-data-binding)
      - [Hello, glimmer_component Rails Helper!](#hello-glimmer_component-rails-helper)
      - [Hello, Input (Date/Time)!](#hello-input-datetime)
      - [Button Counter](#button-counter)
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

[Glimmer DSL for Web](https://rubygems.org/gems/glimmer-dsl-web) will begin by supporting [Opal Ruby](https://opalrb.com/) on [Rails](https://rubyonrails.org/). [Opal](https://opalrb.com/) is a lightweight Ruby to JavaScript transpiler that results in small downloadables compared to WASM. In the future, the project might grow to support [Ruby WASM](https://github.com/ruby/ruby.wasm) as an alternative to [Opal Ruby](https://opalrb.com/) that could be switched to with a simple configuration change.

- Ruby 3.0 (newer Ruby versions are not supported at this time)
- Rails 6-7: [https://github.com/rails/rails](https://github.com/rails/rails)
- Opal 1.4.1 for Rails 6-7: [https://github.com/opal/opal](https://github.com/opal/opal)
- Opal-Rails 2.0.2 for Rails 6-7: [https://github.com/opal/opal-rails](https://github.com/opal/opal-rails)

## Setup

(NOTE: Keep in mind this is an Early Alpha. If you run into issues, try to go back to a [previous revision](https://rubygems.org/gems/glimmer-dsl-web/versions). Also, there is a slight chance any issues you encounter are fixed in master or some other branch that you could check out instead)

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
gem 'glimmer-dsl-web', '~> 0.0.11'
```

Run:

```
bundle
```

(run `rm -rf tmp/cache` from inside your Rails app if you upgrade your `glimmer-dsl-web` gem version from an older one to clear Opal-Rails's cache)

Follow [opal-rails](https://github.com/opal/opal-rails) instructions, basically running:

```
bin/rails g opal:install
```

To enable the `glimmer-dsl-web` library in the frontend, edit `config/initializers/assets.rb` and add the following at the bottom:

```ruby
Opal.use_gem 'glimmer-dsl-web'
Opal.append_path Rails.root.join('app', 'assets', 'opal')
```

To enable Opal Browser Debugging in Ruby with the [Source Maps](https://opalrb.com/docs/guides/v1.4.1/source_maps.html) feature, edit `config/initializers/opal.rb` and add the following inside the `Rails.application.configure do; end` block at the bottom of it:

```ruby
  config.assets.debug = true
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

Clear the file `app/views/welcomes/index.html.erb` completely from all content.

Delete `app/javascript` directory

Rename `app/assets/javascript` directory to `app/assets/opal`.

Add the following lines to `app/assets/config/manifest.js` (and delete their `javascript` equivalents):

```js
//= link_tree ../../opal .js
//= link_directory ../opal .js
```

Rename `app/assets/opal/application.js.rb` to `app/assets/opal/application.rb`.

Edit and replace `app/assets/opal/application.rb` content with code below (optionally including a require statement for one of the [samples](#samples) below inside a `Document.ready? do; end` block):

```ruby
require 'glimmer-dsl-web' # brings opal and other dependencies automatically

# Add more require-statements or Glimmer GUI DSL code
```

Example to confirm setup is working:

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  # This will hook into element #app-container and then build HTML inside it using Ruby DSL code
  div(parent: '#app-container') {
    label(class: 'greeting') {
      'Hello, World!'
    }
  }.render
end
```

That produces:

```html
...
  <div data-parent="body" class="element element-1">
    <label class="greeting element element-2">
      Hello, World!
    </label>
  </div>
...
```

Start the Rails server:
```
rails s
```

Visit `http://localhost:3000`

You should see:

![setup is working](/images/glimmer-dsl-web-setup-example-working.png)

You may insert a Glimmer component anywhere into a Rails View using `glimmer_component(component_path, *args)` Rails helper. Add `include GlimmerHelper` to `ApplicationHelper` or another Rails helper, and use `<%= glimmer_component("path/to/component", *args) %>` in Views.

To use `glimmer_component`, edit `app/helpers/application_helper.rb` in your Rails application, add `require 'glimmer/helpers/glimmer_helper'` on top and `include GlimmerHelper` inside `module`.

`app/helpers/application_helper.rb` should look like this after the change:

```ruby
require 'glimmer/helpers/glimmer_helper'

module ApplicationHelper
  # ...
  include GlimmerHelper
  # ...
end
```

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
gem 'glimmer-dsl-web', '~> 0.0.11'
```

Run:

```
bundle
```

(run `rm -rf tmp/cache` from inside your Rails app if you upgrade your `glimmer-dsl-web` gem version from an older one to clear Opal-Rails's cache)

Follow [opal-rails](https://github.com/opal/opal-rails) instructions, basically running:

```
bin/rails g opal:install
```

To enable the `glimmer-dsl-web` library in the frontend, edit `config/initializers/assets.rb` and add the following at the bottom:

```ruby
Opal.use_gem 'glimmer-dsl-web'
Opal.append_path Rails.root.join('app', 'assets', 'opal')
```

To enable Opal Browser Debugging in Ruby with the [Source Maps](https://opalrb.com/docs/guides/v1.4.1/source_maps.html) feature, edit `config/initializers/opal.rb` and add the following inside the `Rails.application.configure do; end` block at the bottom of it:

```ruby
  config.assets.debug = true
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
```

Also, delete the following line:

```erb
<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
```

Clear the file `app/views/welcomes/index.html.erb` completely from all content.

Rename `app/assets/javascript` directory to `app/assets/opal`.

Add the following lines to `app/assets/config/manifest.js` (and delete their `javascript` equivalents):

```js
//= link_tree ../../opal .js
//= link_directory ../opal .js
```

Rename `app/assets/opal/application.js.rb` to `app/assets/opal/application.rb`.

Edit and replace `app/assets/opal/application.rb` content with code below (optionally including a require statement for one of the [samples](#samples) below inside a `Document.ready? do; end` block):

```ruby
require 'glimmer-dsl-web' # brings opal and other dependencies automatically

# Add more require-statements or Glimmer GUI DSL code
```

Example to confirm setup is working:

Initial HTML Markup:

```html
...
<div id="app-container">
</div>
...
```

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  # This will hook into element #app-container and then build HTML inside it using Ruby DSL code
  div(parent: '#app-container') {
    label(class: 'greeting') {
      'Hello, World!'
    }
  }.render
end
```

That produces:

```html
...
<div id="app-container">
  <div data-parent="#app-container" class="element element-1">
    <label class="greeting element element-2">
      Hello, World!
    </label>
  </div>
</div>
...
```

Start the Rails server:
```
rails s
```

Visit `http://localhost:3000`

You should see:

![setup is working](/images/glimmer-dsl-web-setup-example-working.png)

You may insert a Glimmer component anywhere into a Rails View using `glimmer_component(component_path, *args)` Rails helper. Add `include GlimmerHelper` to `ApplicationHelper` or another Rails helper, and use `<%= glimmer_component("path/to/component", *args) %>` in Views.

To use `glimmer_component`, edit `app/helpers/application_helper.rb` in your Rails application, add `require 'glimmer/helpers/glimmer_helper'` on top and `include GlimmerHelper` inside `module`.

`app/helpers/application_helper.rb` should look like this after the change:

```ruby
require 'glimmer/helpers/glimmer_helper'

module ApplicationHelper
  # ...
  include GlimmerHelper
  # ...
end
```

**NOT RELEASED OR SUPPORTED YET**

If you run into any issues in setup, refer to the [Sample Glimmer DSL for Web Rails 6 App](https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails6-app) project (in case I forgot to include some setup steps by mistake).

Otherwise, if you still cannot setup successfully (even with the help of the sample project, or if the sample project stops working), please do not hesitate to report an [Issue request](https://github.com/AndyObtiva/glimmer-dsl-web/issues) or fix and submit a [Pull Request](https://github.com/AndyObtiva/glimmer-dsl-web/pulls).

## Usage

Glimmer DSL for Web offers a GUI DSL for building HTML Web User Interfaces declaratively in Ruby.

1- **Keywords (HTML Elements)**

You can declare any HTML element by simply using the lowercase version of its name (Ruby convention for method names) like `div`, `span`, `form`, `input`, `button`, `table`, `tr`, `th`, and `td`.

Under the hood, HTML element DSL keywords are invoked as Ruby methods.

2- **Arguments (HTML Attributes + Text Content)**

You can set any HTML element attributes by passing as keyword arguments to element methods like `div(id: 'container', class: 'stack')` or `input(type: 'email', required: true)`

Also, if the element has a little bit of text content that can fit in one line, it can be passed as the 1st argument like `label('Name: ', for: 'name_field')`, `button('Calculate', class: 'round-button')`, or `span('Mr')`

3- **Content Block (Properties + Listeners + Nested Elements + Text Content)**

Element methods can accept a Ruby content block. It intentionally has a `{...}` style even as a multi-line block to indicate that the code is declarative GUI structure code (intentionally breaking away from Ruby imperative code conventions given this is a declarative GUI DSL, meaning a different language that has its own conventions, embedded within Ruby).

You can nest HTML element properties under an element like:

```ruby
input(type: 'text') {
  content_editable false
}
```

You can nest HTML event listeners under an element by using the HTML event listener name (e.g. `onclick`, `onchange`, `onblur`):

```ruby
button('Add') {
  onclick do
    @model.add_selected_element
  end
}
```

Given that listener code is imperative, it uses a `do; end` style for Ruby blocks to separate it from declarative GUI structure code and enable quicker readability of the code.

You can nest other HTML elements under an HTML element the same way you do so in HTML, like:

```ruby
form {
  div(class: 'field-row') {
    label('Name: ', for: 'name-field')
    input(id: 'name-field', class: 'field', type: 'text', required: true)
  }
  div(class: 'field-row') {
    label('Email: ', for: 'email-field')
    input(id: 'email-field', class: 'field', type: 'email', required: true)
  }
  button('Add Contact', class: 'submit-button') {
    onclick do
      ...
    end
  }
}
```

You can nest text content underneath an element's Ruby block provided it is the return value of the block (last declared value), like:

```ruby
p(class: 'summary') {
  'This text content is going into the body of the span element'
}
```

4- **Operations (Properties + Functions)**

You can get/set any element property or invoke any element function by simply calling the lowercase underscored version of their name in Ruby like `input.check_validity`, `input.value`, and `input.id`.

## Supported Glimmer DSL Keywords

[All HTML elements](https://developer.mozilla.org/en-US/docs/Web/HTML/Element), following the Ruby method name standard of lowercase and underscored names.

[All HTML attributes](https://www.w3schools.com/html/html_attributes.asp), following the Ruby method name standard of lowercase and underscored names.

[All HTML events](https://www.w3schools.com/tags/ref_eventattributes.asp), same event attribute names as in HTML.

## Coming from Glimmer DSL for Opal

This project is inspired by [Glimmer DSL for Opal](https://github.com/AndyObtiva/glimmer-dsl-opal) and is similar in enabling frontend GUI development with Ruby. [Glimmer DSL for Web](https://rubygems.org/gems/glimmer-dsl-web) mainly differs from Glimmer DSL for Opal by adopting a DSL that follows web-like HTML syntax in Ruby to facilitate leveraging existing HTML/CSS/JS skills instead of adopting a desktop GUI DSL that is webified. As a result, applications written in Glimmer DSL for Opal are not compatible with Glimmer DSL for Web.

## Samples

This external sample app contains all the samples mentioned below configured inside a Rails [Opal](https://opalrb.com/) app with all the prerequisites ready to go for convenience:

https://github.com/AndyObtiva/sample-glimmer-dsl-web-rails7-app

### Hello Samples

#### Hello, World!

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  div {
    'Hello, World!'
  }.render
end
```

That produces the following under `<body></body>`:

```html
<div data-parent="body" class="element element-1">
  Hello, World!
</div>
```

![setup is working](/images/glimmer-dsl-web-setup-example-working.png)

Alternative syntax (useful when an element has text content that fits in one line):

```ruby
require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  div('Hello, World!').render
end
```

That produces the following under `<body></body>`:

```html
<div data-parent="body" class="element element-1">
  Hello, World!
</div>
```

![setup is working](/images/glimmer-dsl-web-setup-example-working.png)

#### Hello, Button!

Event listeners can be setup on any element using the same event names used in HTML (e.g. `onclick`) while passing in a standard Ruby block to handle behavior. `$$` gives access to `window` to invoke functions like `alert`.

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  div {
    button('Greet') {
      onclick do
        $$.alert('Hello, Button!')
      end
    }
  }.render
end
```

That produces the following under `<body></body>`:

```html
<div data-parent="body" class="element element-1">
  <button class="element element-2">Greet</button>
</div>
```

Screenshot:

![Hello, Button!](/images/glimmer-dsl-web-samples-hello-hello-button.gif)

#### Hello, Form!

[Glimmer DSL for Web](https://rubygems.org/gems/glimmer-dsl-web) gives access to all Web Browser built-in features like HTML form validations, input focus, events, and element functions from a very terse and productive Ruby GUI DSL.

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

include Glimmer

Document.ready? do
  div {
    h1('Contact Form')
    
    form {
      div {
        label('Name: ', for: 'name-field')
        @name_input = input(type: 'text', id: 'name-field', required: true, autofocus: true)
      }
      
      div {
        label('Email: ', for: 'email-field')
        @email_input = input(type: 'email', id: 'email-field', required: true)
      }
      
      div {
        input(type: 'submit', value: 'Add Contact') {
          onclick do |event|
            if ([@name_input, @email_input].all? {|input| input.check_validity })
              # re-open table content and add row
              @table.content {
                tr {
                  td { @name_input.value }
                  td { @email_input.value }
                }
              }
              @email_input.value = @name_input.value = ''
              @name_input.focus
            end
          end
        }
      }
    }
    
    h1('Contacts Table')
    
    @table = table {
      tr {
        th('Name')
        th('Email')
      }
      
      tr {
        td('John Doe')
        td('johndoe@example.com')
      }
      
      tr {
        td('Jane Doe')
        td('janedoe@example.com')
      }
    }
    
    # CSS Styles
    style {
      <<~CSS
        input {
          margin: 5px;
        }
        input[type=submit] {
          margin: 5px 0;
        }
        table {
          border:1px solid grey;
          border-spacing: 0;
        }
        table tr td, table tr th {
          padding: 5px;
        }
        table tr:nth-child(even) {
          background: #ccc;
        }
      CSS
    }
  }.render
end
```

That produces the following under `<body></body>`:

```html
<div data-parent="body" class="element element-1">
  <h1 class="element element-2">Contact Form</h1>
  
  <form class="element element-3">
    <div class="element element-4">
      <label for="name-field" class="element element-5">Name: </label>
      <input type="text" id="name-field" required="true" autofocus="true" class="element element-6">
    </div>
    
    <div class="element element-7">
      <label for="email-field" class="element element-8">Email: </label>
      <input type="email" id="email-field" required="true" class="element element-9">
    </div>
    
    <div class="element element-10">
      <input type="submit" value="Add Contact" class="element element-11">
    </div>
  </form>
  
  <h1 class="element element-12">Contacts Table</h1>
  
  <table class="element element-13">
    <tr class="element element-14">
      <th class="element element-15">Name</th>
      <th class="element element-16">Email</th>
    </tr>
    
    <tr class="element element-17">
      <td class="element element-18">John Doe</td>
      <td class="element element-19">johndoe@example.com</td>
    </tr>
    
    <tr class="element element-20">
      <td class="element element-21">Jane Doe</td>
      <td class="element element-22">janedoe@example.com</td>
    </tr>
  </table>
  
  <style class="element element-23">
    input {
      margin: 5px;
    }
    input[type=submit] {
      margin: 5px 0;
    }
    table {
      border:1px solid grey;
      border-spacing: 0;
    }
    table tr td, table tr th {
      padding: 5px;
    }
    table tr:nth-child(even) {
      background: #ccc;
    }
  </style>
</div>
```

Screenshot:

![Hello, Form!](/images/glimmer-dsl-web-samples-hello-hello-form.gif)

#### Hello, Data-Binding!

[Glimmer DSL for Web](https://rubygems.org/gems/glimmer-dsl-web) intuitively supports both Unidirectional (One-Way) Data-Binding via the `<=` operator and Bidirectional (Two-Way) Data-Binding via the `<=>` operator, incredibly simplifying how to sync View properties with Model attributes with the simplest code to reason about.

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

Address = Struct.new(:street, :street2, :city, :state, :zip_code, keyword_init: true) do
  STATES = {
    "AK"=>"Alaska",
    "AL"=>"Alabama",
    "AR"=>"Arkansas",
    "AS"=>"American Samoa",
    "AZ"=>"Arizona",
    "CA"=>"California",
    "CO"=>"Colorado",
    "CT"=>"Connecticut",
    "DC"=>"District of Columbia",
    "DE"=>"Delaware",
    "FL"=>"Florida",
    "GA"=>"Georgia",
    "GU"=>"Guam",
    "HI"=>"Hawaii",
    "IA"=>"Iowa",
    "ID"=>"Idaho",
    "IL"=>"Illinois",
    "IN"=>"Indiana",
    "KS"=>"Kansas",
    "KY"=>"Kentucky",
    "LA"=>"Louisiana",
    "MA"=>"Massachusetts",
    "MD"=>"Maryland",
    "ME"=>"Maine",
    "MI"=>"Michigan",
    "MN"=>"Minnesota",
    "MO"=>"Missouri",
    "MS"=>"Mississippi",
    "MT"=>"Montana",
    "NC"=>"North Carolina",
    "ND"=>"North Dakota",
    "NE"=>"Nebraska",
    "NH"=>"New Hampshire",
    "NJ"=>"New Jersey",
    "NM"=>"New Mexico",
    "NV"=>"Nevada",
    "NY"=>"New York",
    "OH"=>"Ohio",
    "OK"=>"Oklahoma",
    "OR"=>"Oregon",
    "PA"=>"Pennsylvania",
    "PR"=>"Puerto Rico",
    "RI"=>"Rhode Island",
    "SC"=>"South Carolina",
    "SD"=>"South Dakota",
    "TN"=>"Tennessee",
    "TX"=>"Texas",
    "UT"=>"Utah",
    "VA"=>"Virginia",
    "VI"=>"Virgin Islands",
    "VT"=>"Vermont",
    "WA"=>"Washington",
    "WI"=>"Wisconsin",
    "WV"=>"West Virginia",
    "WY"=>"Wyoming"
  }
  
  def state_code
    STATES.invert[state]
  end
  
  def state_code=(value)
    self.state = STATES[value]
  end

  def summary
    string_attributes = to_h.except(:billing_and_shipping)
    summary = string_attributes.values.map(&:to_s).reject(&:empty?).join(', ')
    summary += " (Billing & Shipping)" if billing_and_shipping
    summary
  end
end

@address = Address.new(
  street: '123 Main St',
  street2: 'Apartment 3C, 2nd door to the right',
  city: 'San Diego',
  state: 'California',
  zip_code: '91911',
  billing_and_shipping: true,
)

include Glimmer

Document.ready? do
  div {
    div(style: 'display: grid; grid-auto-columns: 80px 260px;') { |address_div|
      label('Street: ', for: 'street-field')
      input(id: 'street-field') {
        # Bidirectional Data-Binding with <=> ensures input.value and @address.street
        # automatically stay in sync when either side changes
        value <=> [@address, :street]
      }
      
      label('Street 2: ', for: 'street2-field')
      textarea(id: 'street2-field') {
        value <=> [@address, :street2]
      }
      
      label('City: ', for: 'city-field')
      input(id: 'city-field') {
        value <=> [@address, :city]
      }
      
      label('State: ', for: 'state-field')
      select(id: 'state-field') {
        Address::STATES.each do |state_code, state|
          option(value: state_code) { state }
        end
        
        value <=> [@address, :state_code]
      }
      
      label('Zip Code: ', for: 'zip-code-field')
      input(id: 'zip-code-field', type: 'number', min: '0', max: '99999') {
        # Bidirectional Data-Binding with <=> ensures input.value and @address.zip_code
        # automatically stay in sync when either side changes
        # on_write option specifies :to_s method to invoke on value before writing to model attribute
        # to ensure the numeric zip code value is stored as a String
        value <=> [@address, :zip_code,
                    on_write: :to_s,
                  ]
      }
      
      div(style: 'grid-column: 1 / span 2') {
        input(id: 'billing-and-shipping-field', type: 'checkbox') {
          checked <=> [@address, :billing_and_shipping]
        }
        label(for: 'billing-and-shipping-field') {
          'Use this address for both Billing & Shipping'
        }
      }
      
      style {
        <<~CSS
          #{address_div.selector} * {
            margin: 5px;
          }
          #{address_div.selector} input, #{address_div.selector} select {
            grid-column: 2;
          }
        CSS
      }
    }
  
    div(style: 'margin: 5px') {
      # Unidirectional Data-Binding is done with <= to ensure @address.summary changes
      # automatically update div.inner_text
      # (computed by changes to address attributes, meaning if street changes,
      # @address.summary is automatically recomputed.)
      inner_text <= [@address, :summary,
                      computed_by: @address.members + ['state_code'],
                    ]
    }
  }.render
end
```

Screenshot:

![Hello, Data-Binding!](/images/glimmer-dsl-web-samples-hello-hello-data-binding.gif)

#### Hello, Content Data-Binding!

If you need to regenerate HTML element content dynamically, you can use Content Data-Binding to effortlessly
rebuild HTML elements based on changes in a Model attribute that provides the source data.
In this example, we generate multiple address forms based on the number of addresses the user has.

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

class Address
  attr_accessor :text
  attr_reader :name, :street, :city, :state, :zip
  
  def name=(value)
    @name = value
    update_text
  end
  
  def street=(value)
    @street = value
    update_text
  end
  
  def city=(value)
    @city = value
    update_text
  end
  
  def state=(value)
    @state = value
    update_text
  end
  
  def zip=(value)
    @zip = value
    update_text
  end
  
  private
  
  def update_text
    self.text = [name, street, city, state, zip].compact.reject(&:empty?).join(', ')
  end
end

class User
  attr_accessor :addresses
  attr_reader :address_count
  
  def initialize
    @address_count = 1
    @addresses = []
    update_addresses
  end
  
  def address_count=(value)
    value = [[1, value.to_i].max, 3].min
    @address_count = value
    update_addresses
  end
  
  private
  
  def update_addresses
    address_count_change = address_count - addresses.size
    if address_count_change > 0
      address_count_change.times { addresses << Address.new }
    else
      address_count_change.abs.times { addresses.pop }
    end
  end
end

@user = User.new

include Glimmer

Document.ready? do
  div {
    div {
      label('Number of addresses: ', for: 'address-count-field')
      input(id: 'address-count-field', type: 'number', min: 1, max: 3) {
        value <=> [@user, :address_count]
      }
    }
    
    div {
      # Content Data-Binding is used to dynamically (re)generate content of div
      # based on changes to @user.addresses, replacing older content on every change
      content(@user, :addresses) do
        @user.addresses.each do |address|
          div {
            div(style: 'display: grid; grid-auto-columns: 80px 280px;') { |address_div|
              [:name, :street, :city, :state, :zip].each do |attribute|
                label(attribute.to_s.capitalize, for: "#{attribute}-field")
                input(id: "#{attribute}-field", type: 'text') {
                  value <=> [address, attribute]
                }
              end
              
              div(style: 'grid-column: 1 / span 2;') {
                inner_text <= [address, :text]
              }
              
              style {
                <<~CSS
                  #{address_div.selector} {
                    margin: 10px 0;
                  }
                  #{address_div.selector} * {
                    margin: 5px;
                  }
                  #{address_div.selector} label {
                    grid-column: 1;
                  }
                  #{address_div.selector} input, #{address_div.selector} select {
                    grid-column: 2;
                  }
                CSS
              }
            }
          }
        end
      end
    }
  }.render
end
```

Screenshot:

![Hello, Content Data-Binding!](/images/glimmer-dsl-web-samples-hello-hello-content-data-binding.gif)

#### Hello, Component!

You can define Glimmer web components (View components) to reuse visual concepts to your heart's content,
by simply defining a class with `include Glimmer::Web::Component` and encasing the reusable markup inside
a `markup {...}` block. Glimmer web components automatically extend the Glimmer GUI DSL with new keywords
that match the underscored versions of the component class names (e.g. a `OrderSummary` class yields
the `order_summary` keyword for reusing that component within the Glimmer GUI DSL).
Below, we define an `AddressForm` component that generates a `address_form` keyword, and then we
reuse it twice inside an `AddressPage` component displaying a Shipping Address and a Billing Address.

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

Address = Struct.new(:full_name, :street, :street2, :city, :state, :zip_code, keyword_init: true) do
  STATES = {
    "AK"=>"Alaska",
    "AL"=>"Alabama",
    "AR"=>"Arkansas",
    "AS"=>"American Samoa",
    "AZ"=>"Arizona",
    "CA"=>"California",
    "CO"=>"Colorado",
    "CT"=>"Connecticut",
    "DC"=>"District of Columbia",
    "DE"=>"Delaware",
    "FL"=>"Florida",
    "GA"=>"Georgia",
    "GU"=>"Guam",
    "HI"=>"Hawaii",
    "IA"=>"Iowa",
    "ID"=>"Idaho",
    "IL"=>"Illinois",
    "IN"=>"Indiana",
    "KS"=>"Kansas",
    "KY"=>"Kentucky",
    "LA"=>"Louisiana",
    "MA"=>"Massachusetts",
    "MD"=>"Maryland",
    "ME"=>"Maine",
    "MI"=>"Michigan",
    "MN"=>"Minnesota",
    "MO"=>"Missouri",
    "MS"=>"Mississippi",
    "MT"=>"Montana",
    "NC"=>"North Carolina",
    "ND"=>"North Dakota",
    "NE"=>"Nebraska",
    "NH"=>"New Hampshire",
    "NJ"=>"New Jersey",
    "NM"=>"New Mexico",
    "NV"=>"Nevada",
    "NY"=>"New York",
    "OH"=>"Ohio",
    "OK"=>"Oklahoma",
    "OR"=>"Oregon",
    "PA"=>"Pennsylvania",
    "PR"=>"Puerto Rico",
    "RI"=>"Rhode Island",
    "SC"=>"South Carolina",
    "SD"=>"South Dakota",
    "TN"=>"Tennessee",
    "TX"=>"Texas",
    "UT"=>"Utah",
    "VA"=>"Virginia",
    "VI"=>"Virgin Islands",
    "VT"=>"Vermont",
    "WA"=>"Washington",
    "WI"=>"Wisconsin",
    "WV"=>"West Virginia",
    "WY"=>"Wyoming"
  }
  
  def state_code
    STATES.invert[state]
  end
  
  def state_code=(value)
    self.state = STATES[value]
  end

  def summary
    to_h.values.map(&:to_s).reject(&:empty?).join(', ')
  end
end

# AddressForm Glimmer Web Component (View component)
#
# Including Glimmer::Web::Component makes this class a View component and automatically
# generates a new Glimmer GUI DSL keyword that matches the lowercase underscored version
# of the name of the class. AddressForm generates address_form keyword, which can be used
# elsewhere in Glimmer GUI DSL code as done inside AddressPage below.
class AddressForm
  include Glimmer::Web::Component
  
  option :address
  
  # Optionally, you can execute code before rendering markup.
  # This is useful for pre-setup of variables (e.g. Models) that you would use in the markup.
  #
  # before_render do
  # end
  
  # Optionally, you can execute code after rendering markup.
  # This is useful for post-setup of extra Model listeners that would interact with the
  # markup elements and expect them to be rendered already.
  #
  # after_render do
  # end
  
  # markup block provides the content of the
  markup {
    div {
      div(style: 'display: grid; grid-auto-columns: 80px 260px;') { |address_div|
        label('Full Name: ', for: 'full-name-field')
        input(id: 'full-name-field') {
          value <=> [address, :full_name]
        }
        
        @somelabel = label('Street: ', for: 'street-field')
        input(id: 'street-field') {
          value <=> [address, :street]
        }
        
        label('Street 2: ', for: 'street2-field')
        textarea(id: 'street2-field') {
          value <=> [address, :street2]
        }
        
        label('City: ', for: 'city-field')
        input(id: 'city-field') {
          value <=> [address, :city]
        }
        
        label('State: ', for: 'state-field')
        select(id: 'state-field') {
          Address::STATES.each do |state_code, state|
            option(value: state_code) { state }
          end

          value <=> [address, :state_code]
        }
        
        label('Zip Code: ', for: 'zip-code-field')
        input(id: 'zip-code-field', type: 'number', min: '0', max: '99999') {
          value <=> [address, :zip_code,
                      on_write: :to_s,
                    ]
        }
        
        style {
          <<~CSS
            #{address_div.selector} * {
              margin: 5px;
            }
            #{address_div.selector} input, #{address_div.selector} select {
              grid-column: 2;
            }
          CSS
        }
      }
      
      div(style: 'margin: 5px') {
        inner_text <= [address, :summary,
                        computed_by: address.members + ['state_code'],
                      ]
      }
    }
  }
end

# AddressPage Glimmer Web Component (View component)
#
# This View component represents the main page being rendered,
# as done by its `render` class method below
class AddressPage
  include Glimmer::Web::Component
  
  before_render do
    @shipping_address = Address.new(
      full_name: 'Johnny Doe',
      street: '3922 Park Ave',
      street2: 'PO BOX 8382',
      city: 'San Diego',
      state: 'California',
      zip_code: '91913',
    )
    @billing_address = Address.new(
      full_name: 'John C Doe',
      street: '123 Main St',
      street2: 'Apartment 3C',
      city: 'San Diego',
      state: 'California',
      zip_code: '91911',
    )
  end
  
  markup {
    div {
      h1('Shipping Address')
      
      address_form(address: @shipping_address)
      
      h1('Billing Address')
      
      address_form(address: @billing_address)
    }
  }
end

Document.ready? do
  # renders a top-level (root) AddressPage component
  AddressPage.render
end
```

Screenshot:

![Hello, Component!](/images/glimmer-dsl-web-samples-hello-hello-component.png)

#### Hello, glimmer_component Rails Helper!

You may insert a Glimmer component anywhere into a Rails View using
`glimmer_component(component_path, *args)` Rails helper. Add `include GlimmerHelper` to `ApplicationHelper`
or another Rails helper, and use `<%= glimmer_component("path/to/component", *args) %>` in Views.

Rails `ApplicationHelper` setup code:

```ruby
require 'glimmer/helpers/glimmer_helper'

module ApplicationHelper
  # ...
  include GlimmerHelper
  # ...
end
```

Rails View code:

```erb
<div id="address-container">
  <h1>Shipping Address </h1>
  <legend>Please enter your shipping address information (Zip Code must be a valid 5 digit number)</legend>
  <!-- This sample demonstrates use of glimmer_component helper with arguments -->
  <%= glimmer_component('address_form',
        full_name: params[:full_name],
        street: params[:street],
        street2: params[:street2],
        city: params[:city],
        state: params[:state],
        zip_code: params[:zip_code]
      )
   %>
   <div>
     <a href="/">&lt;&lt; Back Home</a>
   </div>
</div>
```

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

class AddressForm
  Address = Struct.new(:full_name, :street, :street2, :city, :state, :zip_code, keyword_init: true) do
    def state_code
      STATES.invert[state]
    end
    
    def state_code=(value)
      self.state = STATES[value]
    end
  
    def summary
      to_h.values.map(&:to_s).reject(&:empty?).join(', ')
    end
  end
  
  STATES = {
    "AK"=>"Alaska",
    "AL"=>"Alabama",
    "AR"=>"Arkansas",
    "AS"=>"American Samoa",
    "AZ"=>"Arizona",
    "CA"=>"California",
    "CO"=>"Colorado",
    "CT"=>"Connecticut",
    "DC"=>"District of Columbia",
    "DE"=>"Delaware",
    "FL"=>"Florida",
    "GA"=>"Georgia",
    "GU"=>"Guam",
    "HI"=>"Hawaii",
    "IA"=>"Iowa",
    "ID"=>"Idaho",
    "IL"=>"Illinois",
    "IN"=>"Indiana",
    "KS"=>"Kansas",
    "KY"=>"Kentucky",
    "LA"=>"Louisiana",
    "MA"=>"Massachusetts",
    "MD"=>"Maryland",
    "ME"=>"Maine",
    "MI"=>"Michigan",
    "MN"=>"Minnesota",
    "MO"=>"Missouri",
    "MS"=>"Mississippi",
    "MT"=>"Montana",
    "NC"=>"North Carolina",
    "ND"=>"North Dakota",
    "NE"=>"Nebraska",
    "NH"=>"New Hampshire",
    "NJ"=>"New Jersey",
    "NM"=>"New Mexico",
    "NV"=>"Nevada",
    "NY"=>"New York",
    "OH"=>"Ohio",
    "OK"=>"Oklahoma",
    "OR"=>"Oregon",
    "PA"=>"Pennsylvania",
    "PR"=>"Puerto Rico",
    "RI"=>"Rhode Island",
    "SC"=>"South Carolina",
    "SD"=>"South Dakota",
    "TN"=>"Tennessee",
    "TX"=>"Texas",
    "UT"=>"Utah",
    "VA"=>"Virginia",
    "VI"=>"Virgin Islands",
    "VT"=>"Vermont",
    "WA"=>"Washington",
    "WI"=>"Wisconsin",
    "WV"=>"West Virginia",
    "WY"=>"Wyoming"
  }

  include Glimmer::Web::Component
  
  option :full_name
  option :street
  option :street2
  option :city
  option :state
  option :zip_code
  
  attr_reader :address
  
  before_render do
    @address = Address.new(
      full_name: full_name,
      street: street,
      street2: street2,
      city: city,
      state: state,
      zip_code: zip_code,
    )
  end
  
  markup {
    div {
      div(style: 'display: grid; grid-auto-columns: 80px 260px;') { |address_div|
        label('Full Name: ', for: 'full-name-field')
        input(id: 'full-name-field') {
          value <=> [address, :full_name]
        }
        
        @somelabel = label('Street: ', for: 'street-field')
        input(id: 'street-field') {
          value <=> [address, :street]
        }
        
        label('Street 2: ', for: 'street2-field')
        textarea(id: 'street2-field') {
          value <=> [address, :street2]
        }
        
        label('City: ', for: 'city-field')
        input(id: 'city-field') {
          value <=> [address, :city]
        }
        
        label('State: ', for: 'state-field')
        select(id: 'state-field') {
          STATES.each do |state_code, state|
            option(value: state_code) { state }
          end

          value <=> [address, :state_code]
        }
        
        label('Zip Code: ', for: 'zip-code-field')
        input(id: 'zip-code-field', type: 'number', min: '0', max: '99999') {
          value <=> [address, :zip_code,
                      on_write: :to_s,
                    ]
        }
        
        style {
          <<~CSS
            #{address_div.selector} * {
              margin: 5px;
            }
            #{address_div.selector} input, #{address_div.selector} select {
              grid-column: 2;
            }
          CSS
        }
      }
      
      div(style: 'margin: 5px') {
        inner_text <= [address, :summary,
                        computed_by: address.members + ['state_code'],
                      ]
      }
    }
  }
end
```

Screenshot:

![Hello, glimmer_component Rails Helper!](/images/glimmer-dsl-web-samples-hello-hello-component.png)


#### Hello, Input (Date/Time)!

Glimmer GUI code:

```ruby
require 'glimmer-dsl-web'

class TimePresenter
  attr_accessor :date_time, :month_string, :week_string
  
  def initialize
    @date_time = Time.now
  end
  
  def month_string
    @date_time&.strftime('%Y-%m')
  end
  
  def month_string=(value)
    if value.match(/^\d{4}-\d{2}$/)
      year, month = value.split('-')
      self.date_time = Time.new(year, month, date_time.day, date_time.hour, date_time.min)
    end
  end
  
  def week_string
    return nil if @date_time.nil?
    year = @date_time.year
    week = ((@date_time.yday / 7).to_i + 1).to_s.rjust(2, '0')
    "#{year}-W#{week}"
  end
  
  def date_time_string
    @date_time&.strftime('%Y-%m-%dT%H:%M')
  end
  
  def date_time_string=(value)
    if value.match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/)
      date_time_parts = value.split('T')
      date_parts = date_time_parts.first.split('-')
      time_parts = date_time_parts.last.split(':')
      self.date_time = Time.new(*date_parts, *time_parts)
    end
  end
end

@time_presenter = TimePresenter.new

include Glimmer

Document.ready? do
  div {
    div(style: 'display: grid; grid-auto-columns: 130px 260px;') { |container_div|
      label('Date Time: ', for: 'date-time-field')
      input(id: 'date-time-field', type: 'datetime-local') {
        # Bidirectional Data-Binding with <=> ensures input.value and @time_presenter.date_time
        # automatically stay in sync when either side changes
        value <=> [@time_presenter, :date_time]
      }
      
      label('Date: ', for: 'date-field')
      input(id: 'date-field', type: 'date') {
        value <=> [@time_presenter, :date_time]
      }
      
      label('Time: ', for: 'time-field')
      input(id: 'time-field', type: 'time') {
        value <=> [@time_presenter, :date_time]
      }
      
      label('Month: ', for: 'month-field')
      input(id: 'month-field', type: 'month') {
        value <=> [@time_presenter, :month_string, computed_by: :date_time]
      }
      
      label('Week: ', for: 'week-field')
      input(id: 'week-field', type: 'week', disabled: true) {
        value <=> [@time_presenter, :week_string, computed_by: :date_time]
      }
      
      label('Time String: ', for: 'time-string-field')
      input(id: 'time-string-field', type: 'text') {
        value <=> [@time_presenter, :date_time_string, computed_by: :date_time]
      }
      
      style {
        <<~CSS
          #{container_div.selector} * {
            margin: 5px;
          }
          #{container_div.selector} label {
            grid-column: 1;
          }
          #{container_div.selector} input {
            grid-column: 2;
          }
        CSS
      }
    }
  }.render
end
```

Screenshot:

![Hello, Input (Date/Time)!](/images/glimmer-dsl-web-samples-hello-hello-input-date-time.gif)

#### Button Counter

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
    # This will hook into element #app-container and then build HTML inside it using Ruby DSL code
    div(parent: parent_selector) {
      text 'Button Counter'
      
      button {
        # Unidirectional Data-Binding indicating that on every change to @counter.count, the value
        # is read and converted to "Click To Increment: #{value}  ", and then automatically
        # copied to button innerText (content) to display to the user
        inner_text <= [@counter, :count, on_read: ->(value) { "Click To Increment: #{value}  " }]
        
        onclick {
          @counter.increment!
        }
      }
    }
  }
end

HelloButton.render
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

Copyright (c) 2023-2024 - Andy Maleh.
See [LICENSE.txt](LICENSE.txt) for further details.

--

[<img src="https://raw.githubusercontent.com/AndyObtiva/glimmer/master/images/glimmer-logo-hi-res.png" height=40 />](https://github.com/AndyObtiva/glimmer) Built for [Glimmer](https://github.com/AndyObtiva/glimmer) (DSL Framework).
