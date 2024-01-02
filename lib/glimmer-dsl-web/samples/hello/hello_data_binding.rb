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

Address = Struct.new(:street, :street2, :city, :state, :zip_code, :billing_and_shipping, keyword_init: true) do
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
