require 'glimmer-dsl-web'

require_relative 'hello_form_mvp/presenters/hello_form_mvp_presenter'

require_relative 'hello_form_mvp/views/contact_form'
require_relative 'hello_form_mvp/views/contact_table'

class HelloFormMvp
  include Glimmer::Web::Component
  
  before_render do
    @presenter = HelloFormMvpPresenter.new
  end
  
  markup {
    div {
      h1('Contact Form')
      
      contact_form(presenter: @presenter)
      
      h1('Contacts Table')
      
      contact_table(presenter: @presenter)
    }
  }
end

Document.ready? do
  HelloFormMvp.render
end
