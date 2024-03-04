class ContactTable
  include Glimmer::Web::Component
  
  option :presenter
  
  markup {
    table {
      thead {
        tr {
          th('Name')
          th('Email')
        }
      }
      
      tbody {
        content(presenter, :contacts) {
          presenter.contacts.each do |contact|
            tr {
              td(contact.name)
              td(contact.email)
            }
          end
        }
      }
      
      style {
        # CSS can be included as Glimmer DSL for CSS syntax (Ruby code)
        r('table') {
          border '1px solid grey'
          border_spacing '0'
        }
        r('table tr td, table tr th') {
          padding '5px'
        }
        r('table tr:nth-child(even)') {
          background '#ccc'
        }
      }
    }
  }
end
      
