# Copyright (c) 2023-2024 Andy Maleh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
# generates a new Glimmer HTML DSL keyword that matches the lowercase underscored version
# of the name of the class. AddressForm generates address_form keyword, which can be used
# elsewhere in Glimmer HTML DSL code as done inside AddressPage below.
class AddressForm
  include Glimmer::Web::Component
  
  option :address
  
  markup {
    div {
      div(style: {display: :grid, grid_auto_columns: '80px 260px'}) { |address_div|
        label('Full Name: ', for: 'full-name-field')
        input(id: 'full-name-field') {
          value <=> [address, :full_name]
        }
        
        label('Street: ', for: 'street-field')
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
          r("#{address_div.selector} *") {
            margin '5px'
          }
          r("#{address_div.selector} input, #{address_div.selector} select") {
            grid_column '2'
          }
        }
      }
      
      div(style: {margin: 5}) {
        inner_text <= [address, :summary,
                        computed_by: address.members + ['state_code'],
                      ]
      }
    }
  }
end

class Accordion
  class AccordionSectionModel
    attr_accessor :collapsed
    
    def toggle_collapsed
      self.collapsed = !collapsed
    end
  end
  
  include Glimmer::Web::Component
  
  option :size, default: 1
  
  events :accordion_section_expanded, :accordion_section_collapsed
  
  before_render do
    @accordion_section_models = size.times.map { AccordionSectionModel.new }
  end
  
  markup {
    div {
      size.times do |n|
        accordion_section_number = n + 1
        
        section(class: 'accordion-section') {
          class_name(:collapsed) <= [@accordion_section_models[n], :collapsed]
        
          header(slot: "accordion_section#{accordion_section_number}_title", class: 'accordion-section-title') {
            onclick do |event|
              @accordion_section_models[n].toggle_collapsed
              if @accordion_section_models[n].collapsed
                notify_listeners(:accordion_section_collapsed, accordion_section_number)
              else
                notify_listeners(:accordion_section_expanded, accordion_section_number)
              end
            end
          }
          
          div(slot: "accordion_section#{accordion_section_number}_content", class: 'accordion-section-content') { |accordion_section_content|
            on_render do
              # set explicit style height on accordion section content (dynamically calculated on render)
              # to enable CSS transition when its height is set to 0 upon collapse
              accordion_section_content.style_property('height', accordion_section_content.height)
            end
          }
        }
      end
    }
  }
  
  style {
    r('.accordion-section-title') {
      font_size 2.em
      font_weight :bold
      cursor :pointer
      padding_left 20
      position :relative
      margin_block_start 0.33.em
      margin_block_end 0.33.em
    }
    
    r('.accordion-section-title::before') {
      content '"▼"'
      position :absolute
      font_size 0.5.em
      top 10
      left 0
    }
    
    r('.accordion-section-content') {
      overflow :hidden
      transition 'height 0.5s linear'
    }
    
    r('.accordion-section.collapsed .accordion-section-title::before') {
      content '"►"'
    }
    
    r('.accordion-section.collapsed .accordion-section-content') {
      height '0px !important'
    }
  }
end

# AddressPage Glimmer Web Component (View component)
#
# This View component represents the main page being rendered,
# as done by its `render` class method below
class AddressPage
  include Glimmer::Web::Component
  
  attr_accessor :message
  
  before_render do
    @message = '&nbsp;'
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
    # TODO consider adding a 3rd address
  end
  
  markup {
    div {
      h1 {
        inner_html <= [self, :message]
      }
        
      accordion(size: 2) {
        # Refactor to the following to avoid relying on slots, perhaps removing accordion_section_container completely
        # or think if there is a benefit in having a different kind of slot. A slot that can be loaded multiple times
#         accordion_section(title: 'Shipping Address') {
#           address_form(address: @shipping_address)
#         }
#         accordion_section(title: 'Billing Address') {
#           address_form(address: @billing_address)
#         }
        
        accordion_section1_title {
          'Shipping Address'
        }
        accordion_section1_content {
          address_form(address: @shipping_address)
        }
        
        accordion_section2_title {
          'Billing Address'
        }
        accordion_section2_content {
          address_form(address: @billing_address)
        }
        
        # TODO add a 3rd address to demonstrate how expanding one address collapses all others
        
        on_accordion_section_expanded { |accordion_section_number|
          self.message = "Accordion section #{accordion_section_number} is expanded!"
        }
        
        on_accordion_section_collapsed { |accordion_section_number|
          self.message = "Accordion section #{accordion_section_number} is collapsed!"
        }
      }
    }
  }
end

Document.ready? do
  # renders a top-level (root) AddressPage component
  AddressPage.render
end
