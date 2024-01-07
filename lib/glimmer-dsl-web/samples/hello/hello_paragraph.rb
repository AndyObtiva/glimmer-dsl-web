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

class HelloParagraph
  include Glimmer::Web::Component
  
  markup {
    div {
      h1(class: 'title') {
        'Flying Cars Become 100% Safe with AI Powered Balance!'
      }
      
      p(class: 'intro') {"
        In the early 2030's, #{em('flying cars')} became affordable after their prices dropped
        below #{small(del('$100,000'))}#{ins('$80,000')} as a result of the innovations of #{strong('Travel-X')}. Still, that did not
        make #{em('flying cars')} any popular due to the extreme difficulty in piloting such flying vehicles for the average
        person, making it very tough to pass the tests for getting a piloting license given the learning curve.
      "}
      
      p {"
        That said, #{b('Travel-X')} has recently come up with a new feature for their flagship #{i('flying car')},
        the Ptero#{sub(1)}#{sup('TM')}, which relies on AI#{sub(2)} to automatically balance the flying cars in mid-air,
        thus significantly facilitating their piloting by the average consumer.
      "}
      
      p(class: 'conclusion') {"
        That Ptero#{sup('TM')} will be so stable and well balanced while flying that the consumer will be able to drive
        as if it is a plain old car, with the only difference being vertical elevation, the control of which will be handled
        automatically by AI. The Ptero#{sup('TM')} will debut for #{span(style: 'text-decoration: underline dashed;'){'$79,000'}}.
      "}
      
      h2(class: 'legend-title') {
        mark('Legend:')
      }
      
      p(class: 'legend') {"
        #{strong("1- Ptero:")} Pterosaur is flying dinosaur species#{br}
        #{strong("2- AI:")} Artificial Intelligence#{br}
      "}
        
    }
  }
end

Document.ready? do
  HelloParagraph.render
end
