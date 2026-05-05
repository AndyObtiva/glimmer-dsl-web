require 'glimmer-dsl-web'

# only in the sample we need the unless statement to avoid conflicting with other samples, but not in real usage
unless Object.const_defined?(:GreetingPerson)
  GreetingPerson = Struct.new(:name, keyword_init: true)
end

# only in the sample we need the unless statement to avoid conflicting with other samples, but not in real usage
unless Object.const_defined?(:GreetingModal)
  class GreetingModal
    include Glimmer::Web::Component
    
    attribute :greeting_target, default: 'World'
    
    markup {
      div(class: 'modal-outer') {
        div(class: 'modal-inner') {
          h2 { 'Greeting' }
          
          h3 { "Hello, #{greeting_target}!" }
          
          div {
            button('Close') {
              onclick do
                markup_root.remove
              end
            }
          }
        }
      }
    }
    
    style {
      r('.modal-outer') {
        display 'flex'
        position 'fixed'
        left 0
        top 0
        width 100.vw
        height 100.vh
        background 'rgba(200, 200, 200, 0.8)'
        margin 0
        padding 0
        justify_content 'center'
        align_items 'center'
      }
      
      r('div.modal-inner') {
        display 'flex'
        flex_direction 'column'
        width 300
        height 160
        justify_content 'center'
        align_items 'center'
        box_shadow '0 10px 30px rgba(0, 0, 0, 0.5)'
        background :white
        border_radius 15
        padding 15
      }
      
      r('div.modal-inner button') {
        width 135
        margin 5
        border_radius 5
        padding 5
        background :white
      }
      
      r('div.modal-inner button:hover') {
        background :black
        color :white
      }
      
      
      r('div.modal-inner h2') {
        margin_top 10
      }
    }
  end
end

# only in the sample we need the unless statement to avoid conflicting with other samples, but not in real usage
unless Object.const_defined?(:HelloModal)
  class HelloModal
    include Glimmer::Web::Component
    
    before_render do
      @greeting_person = GreetingPerson.new
    end
    
    markup {
      div {
        div {
          button('Greet The World') {
            onclick do
              # renders Modal under body by default, which works for Modals because they rely on fixed positioning
              GreetingModal.render
            end
          }
        }
        div {
          button('Greet Laura') {
            onclick do
              # renders Modal under body explicitly (parent takes a CSS expression) while passing it an attribute value
              GreetingModal.render(parent: 'body', greeting_target: 'Laura')
            end
          }
        }
        div {
          label { 'Greeting Person Name:' }
          input(type: 'text') {
            value <=> [@greeting_person, :name]
          }
          button {
            inner_text <= [@greeting_person, :name, on_read: ->(name) { "Greet #{name}" }]
            
            onclick do
              # renders Modal under body by default while passing it a Model attribute value
              GreetingModal.render(greeting_target: @greeting_person.name)
            end
          }
        }
      }
    }
    
    style {
      r('.hello-modal div') {
        margin_bottom 10
      }
      r('.hello-modal label, .hello-modal input, .hello-modal button') {
        margin_right 5
      }
    }
  end
end

# only in the sample we need the Document.ready? call; in real usage,
# we rely on the glimmer_component helper to load this file inside a Rails View
Document.ready? do
  HelloModal.render
end
