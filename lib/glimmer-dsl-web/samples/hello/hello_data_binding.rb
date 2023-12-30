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
      # TODO switch to a select
      input(id: 'state-field') {
        value <=> [@address, :state]
      }
      
      label('Zip Code: ', for: 'zip-code-field')
      input(id: 'zip-code-field') {
        value <=> [@address, :zip_code]
      }
    
      div(style: 'grid-column: 1 / span 2') {
        inner_text <= [@address, :summary, computed_by: @address.members]
      }
      
      style {
        <<~CSS
          .#{address_form.element_id} * { margin: 5px; }
        CSS
      }
    }
  }.render
end
