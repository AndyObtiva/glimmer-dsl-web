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
  WIDTH_MIN = 160
  WIDTH_MAX = 960
  HEIGHT_MIN = 100
  HEIGHT_MAX = 600
  FONT_SIZE_MIN = 40
  FONT_SIZE_MAX = 200
  
  attr_accessor :text, :pushed, :width, :height, :font_size
  
  def initialize
    @text = 'Push'
    @width = WIDTH_MIN
    @height = HEIGHT_MIN
    @font_size = FONT_SIZE_MIN
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
      
      style <= [ button_model, :width,
                 on_read: method(:button_style_value) # convert value on read before storing in style
               ]
      
      style <= [ button_model, :height,
                 on_read: method(:button_style_value) # convert value on read before storing in style
               ]
      
      style <= [ button_model, :font_size,
                 on_read: method(:button_style_value) # convert value on read before storing in style
               ]
      
      onclick do
        button_model.push
      end
    }
  }
  
  style {'
    button {
      font-family: Courrier New, Courrier;
      border-radius: 5px;
      border-width: 17px;
      border-color: #ACC7D5;
      background-color: #ADD8E6;
      margin: 5px;
    }
    
    button.pulled {
      border-style: outset;
    }
    
    button.pushed {
      border-style: inset;
    }
  '}
  
  def button_style_value
    "
      width: #{button_model.width}px;
      height: #{button_model.height}px;
      font-size: #{button_model.font_size}px;
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

class HelloStyle
  include Glimmer::Web::Component
  
  before_render do
    @button_model = ButtonModel.new
  end
  
  markup {
    div(class: 'hello-style') {
      div(class: 'form-row') {
        label('Styled Button Width:', for: 'styled-button-width-input')
        styled_button_range_input(button_model: @button_model, property: :width, property_min: ButtonModel::WIDTH_MIN, property_max: ButtonModel::WIDTH_MAX, id: 'styled-button-width-input')
      }
      div(class: 'form-row') {
        label('Styled Button Height:', for: 'styled-button-height-input')
        styled_button_range_input(button_model: @button_model, property: :height, property_min: ButtonModel::HEIGHT_MIN, property_max: ButtonModel::HEIGHT_MAX, id: 'styled-button-height-input')
      }
      div(class: 'form-row') {
        label('Styled Button Font Size:', for: 'styled-button-font-size-input')
        styled_button_range_input(button_model: @button_model, property: :font_size, property_min: ButtonModel::FONT_SIZE_MIN, property_max: ButtonModel::FONT_SIZE_MAX, id: 'styled-button-font-size-input')
      }
      styled_button(button_model: @button_model)
    }
  }
  
  style {'
    .hello-style {
      padding: 20px;
    }
    
    .hello-style .form-row {
      margin: 10px 0;
    }
  '}
end

Document.ready? do
  HelloStyle.render
end
