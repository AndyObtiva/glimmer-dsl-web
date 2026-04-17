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
