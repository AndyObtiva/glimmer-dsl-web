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

class ButtonModel
  BUTTON_STYLE_ATTRIBUTES = [
    :width, :height, :font_size,
    :background_color_red, :background_color_green, :background_color_blue
  ]
  WIDTH_MIN = 160
  WIDTH_MAX = 960
  HEIGHT_MIN = 100
  HEIGHT_MAX = 600
  FONT_SIZE_MIN = 40
  FONT_SIZE_MAX = 200
  
  attr_accessor :text, :pushed, *BUTTON_STYLE_ATTRIBUTES
  
  def initialize
    @text = 'Push'
    @width = WIDTH_MIN
    @height = HEIGHT_MIN
    @font_size = FONT_SIZE_MIN
    @background_color_red = 173
    @background_color_green = 216
    @background_color_blue = 230
  end
  
  def push
    self.pushed = !pushed
  end
  
  def text
    pushed ? 'Pull' : 'Push'
  end
  
  def width=(value)
    @width = value
    self.font_size = @width/4 if @font_size > @width/4
  end
  
  def height=(value)
    @height = value
    self.font_size = @height/2.5 if @font_size > @height/2.5
  end
  
  def font_size=(value)
    @font_size = value
    self.width = @font_size*4 if @height < @font_size*4
    self.height = @font_size*2.5 if @height < @font_size*2.5
  end
end

class StyledButton
  include Glimmer::Web::Component
  
  option :button_model
  
  markup {
    button {
      inner_text <= [button_model, :text, computed_by: :pushed]
      
      class_name <= [button_model, :pushed,
                      on_read: ->(pushed) { pushed ? 'pushed' : 'pulled' }
                    ]
      
      ButtonModel::BUTTON_STYLE_ATTRIBUTES.each do |attribute|
        style <= [ button_model, attribute,
                   on_read: method(:button_style_value) # convert value on read before storing in style
                 ]
      end
      
      onclick do
        button_model.push
      end
    }
  }
  
  style {"
    .#{component_element_class} {
      font-family: Courrier New, Courrier;
      border-radius: 5px;
      border-width: 17px;
      margin: 5px;
    }
    
    .#{component_element_class}.pulled {
      border-style: outset;
    }
    
    .#{component_element_class}.pushed {
      border-style: inset;
    }
  "}
  
  def button_style_value
    "
      width: #{button_model.width}px;
      height: #{button_model.height}px;
      font-size: #{button_model.font_size}px;
      background-color: rgb(#{button_model.background_color_red}, #{button_model.background_color_green}, #{button_model.background_color_blue});
      border-color: rgb(#{button_model.background_color_red - 10}, #{button_model.background_color_green - 10}, #{button_model.background_color_blue - 10});
    "
  end
end

class StyledButtonRangeInput
  include Glimmer::Web::Component
  
  option :button_model
  option :property
  option :property_min
  option :property_max
  
  markup {
    input(type: 'range', min: property_min, max: property_max) {
      value <=> [button_model, property]
    }
  }
end

class StyledButtonColorRangeInput
  include Glimmer::Web::Component
  
  COLORS = [:red, :green, :blue]
  
  option :button_model
  option :property
  option :color
  
  markup {
    input(type: 'range', min: 0, max: 255) {
      value <=> [button_model, "#{property}_#{color}"]
    }
  }
end

class HelloStyle
  include Glimmer::Web::Component
  
  before_render do
    @button_model = ButtonModel.new
  end
  
  markup {
    div {
      div(class: 'styled-button-form') {
        label('Styled Button Width:', class: 'property-label', for: 'styled-button-width-input')
        styled_button_range_input(button_model: @button_model, property: :width, property_min: ButtonModel::WIDTH_MIN, property_max: ButtonModel::WIDTH_MAX, id: 'styled-button-width-input')
        
        label('Styled Button Height:', class: 'property-label', for: 'styled-button-height-input')
        styled_button_range_input(button_model: @button_model, property: :height, property_min: ButtonModel::HEIGHT_MIN, property_max: ButtonModel::HEIGHT_MAX, id: 'styled-button-height-input')
        
        label('Styled Button Font Size:', class: 'property-label', for: 'styled-button-font-size-input')
        styled_button_range_input(button_model: @button_model, property: :font_size, property_min: ButtonModel::FONT_SIZE_MIN, property_max: ButtonModel::FONT_SIZE_MAX, id: 'styled-button-font-size-input')
        
        label('Styled Button Background Color:', for: 'styled-button-background-color-input')
        
        StyledButtonColorRangeInput::COLORS.each do |color|
          input_id = "styled-button-background-color-#{color}-input"
          label("#{color.to_s.capitalize}:", class: 'color-label', for: input_id)
          styled_button_color_range_input(button_model: @button_model, property: :background_color, color: color, id: input_id)
        end
      }
      
      styled_button(button_model: @button_model)
    }
  }
  
  style {"
    .styled-button-form {
      padding: 20px;
      display: inline-grid;
      grid-template-columns: auto auto;
    }
    
    .styled-button-form label, input {
      display: block;
      margin: 5px 5px 5px 0;
    }
    
    .styled-button-form label[for=styled-button-background-color-input] {
      grid-column: 1 / 3;
    }
    
    .styled-button-form .color-label {
      margin-left: 5px;
    }
    
    .#{component_element_class} .styled-button {
      display: block;
    }
  "}
end

Document.ready? do
  HelloStyle.render
end
