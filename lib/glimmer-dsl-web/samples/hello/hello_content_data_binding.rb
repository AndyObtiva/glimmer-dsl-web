require 'glimmer-dsl-web'

# Note: named Address2 to avoid conflicting with other samples if loaded together
class Address2
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
      address_count_change.times { addresses << Address2.new }
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
      # based on changes to @user.address_count, replacing older content on every change
      content(@user, :address_count) do
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
                r(address_div.selector) {
                  margin '10px 0'
                }
                r("#{address_div.selector} *") {
                  margin '5px'
                }
                r("#{address_div.selector} label") {
                  grid_column '1'
                }
                r("#{address_div.selector} input, #{address_div.selector} select") {
                  grid_column '2'
                }
              }
            }
          }
        end
      end
    }
  }
end
