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
          r("#{address_div.selector} *") {
            margin '5px'
          }
          r("#{address_div.selector} input, #{address_div.selector} select") {
            grid_column '2'
          }
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
