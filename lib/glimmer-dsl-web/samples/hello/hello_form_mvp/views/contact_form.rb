class ContactForm
  include Glimmer::Web::Component
  
  option :presenter
  
  markup {
    form {
      div {
        label('Name: ', for: 'name-field')
        @name_input = input(:required, :autofocus, type: 'text', id: 'name-field') {
          value <=> [presenter.new_contact, :name]
        }
      }
      
      div {
        label('Email: ', for: 'email-field')
        @email_input = input(:required, type: 'email', id: 'email-field') {
          value <=> [presenter.new_contact, :email]
        }
      }
      
      div {
        input(type: 'submit', value: 'Add Contact') {
          onclick do |event|
            if [@name_input, @email_input].all?(&:check_validity)
              event.prevent_default
              # adding contact model to presenter contacts array indirectly updates contacts table
              presenter.add_contact
              @name_input.focus
            end
          end
        }
      }
      
      style {
        # CSS can be included as Glimmer DSL for CSS syntax (Ruby code)
        r('input') {
          margin '5px'
        }
        r('input[type=submit]') {
          margin '5px 0'
        }
      }
    }
  }
end
