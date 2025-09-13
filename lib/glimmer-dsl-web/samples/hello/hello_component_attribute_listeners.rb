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

unless Object.const_defined?(:AddressTypeSelector)
  class AddressTypeSelector
    include Glimmer::Web::Component
    
    attribute :address_types, default: []
    attribute :selected_address_type
    
    before_render do
      self.selected_address_type ||= address_types.first
    end
    
    markup {
      select(placeholder: 'Select an address type') { |select_element|
        address_types.each do |address_type|
          option(value: address_type) { address_type }
        end
        
        # Bidirectionally data-bind select value to selected_address_type attribute on self (component)
        value <=> [self, :selected_address_type]
      }
    }
    
    style {
      r(component_element_selector) {
        font_size 2.em
        margin_left 5.px
      }
    }
  end
end

unless Object.const_defined?(:AddressTypeSelectorPage)
  class AddressTypeSelectorPage
    include Glimmer::Web::Component
    
    markup {
      div {
        h1('Address type for delivery:', style: {display: :inline})
        
        address_type_selector(address_types: ['Home', 'Work', 'Other']) {
          # We can listen to the updates of any attribute/option in a Glimmer Web Component
          # on_{attribute_name}_update do execute code when component attribute/option with attribute_name is updated
          # This is an alternative to using Component Listeners, which require that the component explicitly calls notify_listeners,
          # whereas Component Attribute Listeners get tracked automatically, but depend on a specific attribute
          # The trade-off is Component Listeners provide more flexibility when needed as they are not bound to specific attributes,
          # but often Component Attribute Listeners are good enough as a solution for certain problems.
          on_selected_address_type_update do |address_type|
            $$.alert("You selected the address type: #{address_type}")
          end
        }
      }
    }
  end
end

Document.ready? do
  AddressTypeSelectorPage.render
end
