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
  attr_accessor :text, :pushed
  
  def initialize
    @text = 'Push'
  end
  
  def push
    self.pushed = !pushed
  end
  
  def text
    pushed ? 'Pull' : 'Push'
  end
end

class StyledButton
  include Glimmer::Web::Component
  
  option :text
  
  before_render do
    @button_model = ButtonModel.new
  end
  
  markup {
    button {
      class_name <= [@button_model, :pushed,
                      on_read: ->(pushed) { pushed ? 'pushed' : 'pulled' }
                    ]
                    
      inner_html <= [@button_model, :text, computed_by: :pushed]
      
      onclick do
        @button_model.push
      end
    }
  }
  
  style {'
    button {
      font-size: 60px;
      font-family: Courrier New, Courrier;
      border-radius: 5px;
      border-width: 17px;
      border-color: lightgrey;
    }
    
    button.pulled {
      border-style: outset;
    }
    
    button.pushed {
      border-style: inset;
    }
  '}
end

class HelloStyle
  include Glimmer::Web::Component
  
  markup {
    div(class: 'hello-style') {
      styled_button(text: 'Push Me') {
      }
      button('Remove') {
        onclick { remove }
      }
    }
  }
  
  style {'
    .hello-style {
      padding: 20px;
    }
  '}
end

Document.ready? do
  HelloStyle.render
end
