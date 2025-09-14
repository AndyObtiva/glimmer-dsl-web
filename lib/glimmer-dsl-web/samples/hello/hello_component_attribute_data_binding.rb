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

unless Object.const_defined?(:AddressTypePresenter)
  class AddressTypePresenter
    attr_accessor :address_types, :selected_address_type
    
    def initialize(address_types:, selected_address_type: nil)
      @address_types = address_types
      @selected_address_type = selected_address_type
      @selected_address_type ||= address_types.first
    end
  end
end

unless Object.const_defined?(:AddressTypeSelect)
  class AddressTypeSelect
    include Glimmer::Web::Component
    
    attribute :address_types, default: []
    attribute :selected_address_type
    
    markup {
      select { |select_element|
        address_types.each do |address_type|
          option(value: address_type) { address_type }
        end
        
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

unless Object.const_defined?(:AddressTypeRadioGroup)
  class AddressTypeRadioGroup
    include Glimmer::Web::Component
    
    attribute :address_types, default: []
    attribute :selected_address_type
    
    markup {
      div { |select_element|
        address_types.each do |address_type|
          input_id = "radio_address_type_#{address_type}"
          input(id: input_id, type: 'radio', name: 'radio_address_type', value: address_type) {
            checked <=> [self, :selected_address_type,
                         on_read: ->(address_type_string_value) { address_type_string_value == address_type },
                         on_write: ->(radio_input_boolean_value) { radio_input_boolean_value ? address_type : selected_address_type },
                        ]
          }
          label(for: input_id) { address_type }
        end
      }
    }
    
    style {
      r(component_element_selector) {
        font_size 2.em
        margin_top 10.px
      }
      r("#{component_element_selector} label") {
        margin_left 2.px
        margin_right 10.px
      }
    }
  end
end

unless Object.const_defined?(:AddressTypeComponentAttributeDataBindingPage)
  class AddressTypeComponentAttributeDataBindingPage
    include Glimmer::Web::Component
    
    before_render do
      @presenter = AddressTypePresenter.new(address_types: ['Home', 'Work', 'Other'])
    end
    
    markup {
      div {
        h1('Address type for delivery:')
        
        address_type_select(address_types: @presenter.address_types, selected_address_type: @presenter.selected_address_type) {
          # Not only can we data-bind attributes on basic HTML elements,
          # but we can also data-bind custom attributes on Glimmer Web Components
          selected_address_type <=> [@presenter, :selected_address_type]
        }
        
        address_type_radio_group(address_types: @presenter.address_types, selected_address_type: @presenter.selected_address_type) {
          # Not only can we data-bind attributes on basic HTML elements,
          # but we can also data-bind custom attributes on Glimmer Web Components
          selected_address_type <=> [@presenter, :selected_address_type]
        }
      }
    }
  end
end

Document.ready? do
  AddressTypeComponentAttributeDataBindingPage.render
end
