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

unless Object.const_defined?(:Address)
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
end

unless Object.const_defined?(:AddressForm)
  # AddressForm Glimmer Web Component (View component)
  #
  # Including Glimmer::Web::Component makes this class a View component and automatically
  # generates a new Glimmer HTML DSL keyword that matches the lowercase underscored version
  # of the name of the class. AddressForm generates address_form keyword, which can be used
  # elsewhere in Glimmer HTML DSL code as done inside HelloComponentListeners below.
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
end

unless Object.const_defined?(:AccordionSection)
  class AccordionSection
    class Presenter
      attr_accessor :collapsed, :instant_transition
      
      def toggle_collapsed(instant: false)
        self.instant_transition = instant
        self.collapsed = !collapsed
      end
      
      def expand(instant: false)
        self.instant_transition = instant
        self.collapsed = false
      end
      
      def collapse(instant: false)
        self.instant_transition = instant
        self.collapsed = true
      end
    end
    
    include Glimmer::Web::Component
    
    events :expanded, :collapsed
    
    default_slot :section_content # automatically insert content in this element slot inside markup
    
    option :title
    
    attr_reader :presenter
    
    before_render do
      @presenter = Presenter.new
    end
    
    markup {
      section { # represents the :markup_root_slot to allow inserting content here instead of in default_slot
        # Unidirectionally data-bind the class inclusion of 'collapsed' to the @presenter.collapsed boolean attribute,
        # meaning if @presenter.collapsed changes to true, the CSS class 'collapsed' is included on the element,
        # and if it changes to false, the CSS class 'collapsed' is removed from the element.
        class_name(:collapsed) <= [@presenter, :collapsed]
        class_name(:instant_transition) <= [@presenter, :instant_transition]
      
        header(title, class: 'accordion-section-title') {
          onclick do |event|
            @presenter.toggle_collapsed
            if @presenter.collapsed
              notify_listeners(:collapsed)
            else
              notify_listeners(:expanded)
            end
          end
        }
        
        div(slot: :section_content, class: 'accordion-section-content')
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
        height 246
        overflow :hidden
        transition 'height 0.5s linear'
      }
      
      r("#{component_element_selector}.instant_transition .accordion-section-content") {
        transition 'initial'
      }
      
      r("#{component_element_selector}.collapsed .accordion-section-title::before") {
        content '"►"'
      }
      
      r("#{component_element_selector}.collapsed .accordion-section-content") {
        height 0
      }
    }
  end
end

unless Object.const_defined?(:Accordion)
  class Accordion
    include Glimmer::Web::Component
    
    events :accordion_section_expanded, :accordion_section_collapsed
    
    markup {
      # given that no slots are specified, nesting content under the accordion component
      # in consumer code adds content directly inside the markup root div.
      div { |accordion| # represents the :markup_root_slot (top-level element)
        # on render, all accordion sections would have been added by consumers already, so we can
        # attach listeners to all of them by re-opening their content with `.content { ... }` block
        on_render do
          accordion_section_elements = accordion.children
          accordion_sections = accordion_section_elements.map(&:component)
          accordion_sections.each_with_index do |accordion_section, index|
            accordion_section_number = index + 1
  
            # ensure only the first section is expanded
            accordion_section.presenter.collapse(instant: true) if accordion_section_number != 1
  
            accordion_section.content { # re-open content and add component custom event listeners
              on_expanded do
                other_accordion_sections = accordion_sections.reject {|other_accordion_section| other_accordion_section == accordion_section }
                other_accordion_sections.each { |other_accordion_section| other_accordion_section.presenter.collapse }
                notify_listeners(:accordion_section_expanded, accordion_section_number)
              end
  
              on_collapsed do
                notify_listeners(:accordion_section_collapsed, accordion_section_number)
              end
            }
          end
        end
      }
    }
  end
end

unless Object.const_defined?(:HelloComponentListeners)
  # HelloComponentListeners Glimmer Web Component (View component)
  #
  # This View component represents the main page being rendered,
  # as done by its `render` class method below
  class HelloComponentListeners
    class Presenter
      attr_accessor :status_message
      
      def initialize
        @status_message = "Accordion section 1 is expanded!"
      end
    end
    
    include Glimmer::Web::Component
    
    before_render do
      @presenter = Presenter.new
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
      @emergency_address = Address.new(
        full_name: 'Mary Doe',
        street: '2038 Ipswitch St',
        street2: 'Suite 300',
        city: 'San Diego',
        state: 'California',
        zip_code: '91912',
      )
    end
    
    markup {
      div {
        h1(style: {font_style: :italic}) {
          inner_html <= [@presenter, :status_message]
        }
          
        accordion {
          # any content nested under component directly is added to its markup_root_slot element if no default_slot is specified
          accordion_section(title: 'Shipping Address') {
            address_form(address: @shipping_address) # automatically inserts content in default_slot :section_content
          }
          
          accordion_section(title: 'Billing Address') {
            address_form(address: @billing_address) # automatically inserts content in default_slot :section_content
          }
          
          accordion_section(title: 'Emergency Address') {
            address_form(address: @emergency_address) # automatically inserts content in default_slot :section_content
          }
          
          # on_accordion_section_expanded listener matches event :accordion_section_expanded declared in Accordion component
          on_accordion_section_expanded { |accordion_section_number|
            @presenter.status_message = "Accordion section #{accordion_section_number} is expanded!"
          }
          
          on_accordion_section_collapsed { |accordion_section_number|
            @presenter.status_message = "Accordion section #{accordion_section_number} is collapsed!"
          }
        }
      }
    }
  end
end

Document.ready? do
  # renders a top-level (root) HelloComponentListeners component
  HelloComponentListeners.render
end
