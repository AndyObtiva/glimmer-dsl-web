require 'glimmer-dsl-web'

class BackLink
  include Glimmer::Web::Component
  
  attribute :text, default: 'Back'
  
  markup {
    a(text, href: '') {
      onclick do |event|
        event.prevent_default
        $$.history.back
      end
    }
  }
end
