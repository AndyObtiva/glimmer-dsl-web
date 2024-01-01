# Copyright (c) 2023 Andy Maleh
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

Address = Struct.new(:street, :city, :state, :zip_code, keyword_init: true) do
  STATES = [
    ["AK", "Alaska"],
    ["AL", "Alabama"],
    ["AR", "Arkansas"],
    ["AS", "American Samoa"],
    ["AZ", "Arizona"],
    ["CA", "California"],
    ["CO", "Colorado"],
    ["CT", "Connecticut"],
    ["DC", "District of Columbia"],
    ["DE", "Delaware"],
    ["FL", "Florida"],
    ["GA", "Georgia"],
    ["GU", "Guam"],
    ["HI", "Hawaii"],
    ["IA", "Iowa"],
    ["ID", "Idaho"],
    ["IL", "Illinois"],
    ["IN", "Indiana"],
    ["KS", "Kansas"],
    ["KY", "Kentucky"],
    ["LA", "Louisiana"],
    ["MA", "Massachusetts"],
    ["MD", "Maryland"],
    ["ME", "Maine"],
    ["MI", "Michigan"],
    ["MN", "Minnesota"],
    ["MO", "Missouri"],
    ["MS", "Mississippi"],
    ["MT", "Montana"],
    ["NC", "North Carolina"],
    ["ND", "North Dakota"],
    ["NE", "Nebraska"],
    ["NH", "New Hampshire"],
    ["NJ", "New Jersey"],
    ["NM", "New Mexico"],
    ["NV", "Nevada"],
    ["NY", "New York"],
    ["OH", "Ohio"],
    ["OK", "Oklahoma"],
    ["OR", "Oregon"],
    ["PA", "Pennsylvania"],
    ["PR", "Puerto Rico"],
    ["RI", "Rhode Island"],
    ["SC", "South Carolina"],
    ["SD", "South Dakota"],
    ["TN", "Tennessee"],
    ["TX", "Texas"],
    ["UT", "Utah"],
    ["VA", "Virginia"],
    ["VI", "Virgin Islands"],
    ["VT", "Vermont"],
    ["WA", "Washington"],
    ["WI", "Wisconsin"],
    ["WV", "West Virginia"],
    ["WY", "Wyoming"]
  ].to_h
  
  def state_code
    STATES.invert[state]
  end
  
  def state_code=(value)
    self.state = STATES[value]
  end

  def summary
    values.map(&:to_s).reject(&:empty?).join(', ')
  end
end

@address = Address.new(street: '123 Main St', city: 'Chicago', state: 'IL', zip_code: '60662')

include Glimmer

Document.ready? do
  div {
    form(style: 'display: grid; grid-auto-columns: 80px 180px;') { |address_form|
      label('Street: ', for: 'street-field')
      input(id: 'street-field') {
        value <=> [@address, :street]
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
      input(id: 'zip-code-field') {
        value <=> [@address, :zip_code]
      }
    
      div(style: 'grid-column: 1 / span 2') {
        inner_text <= [@address, :summary, computed_by: @address.members + ['state_code']]
      }
      
      style {
        <<~CSS
          .#{address_form.element_id} * { margin: 5px; }
        CSS
      }
    }
  }.render
end
