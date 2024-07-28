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

class HelloSvg
  include Glimmer::Web::Component
  
  markup {
    div {
      svg(width: '100%', height: '100') {
        circle(cx: '50', cy: '50', r: '50', style: 'fill:blue;') {
          animate(attributename: 'cx', begin: '0s', dur: '8s', from: '50', to: '90%', repeatcount: 'indefinite')
        }
      }
      svg(width: '200', height: '180') {
        rect(x: '30', y: '30', height: '110', width: '110', style: 'stroke:green;fill:red') {
          animatetransform(attributename: 'transform', begin: '0.1s', dur: '10s', type: 'rotate', from: '0 85 85', to: '360 85 85', repeatcount: 'indefinite')
        }
      }
    }
  }
end

Document.ready? do
  HelloSvg.render
end
