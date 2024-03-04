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
