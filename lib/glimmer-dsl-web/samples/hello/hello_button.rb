# Copyright (c) 2023 Andy Maleh
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

include Glimmer

Document.ready? do
  div {
    h1('Contact Form')
    form {
      div(class: 'field-row') {
        label('Name: ', for: 'name-field')
        @name_input = input(id: 'name-field', class: 'field', type: 'text', required: true)
      }
      div(class: 'field-row') {
        label('Email: ', for: 'email-field')
        @email_input = input(id: 'email-field', class: 'field', type: 'email', required: true)
      }
      button('Add Contact', class: 'submit-button') {
        onclick do
          if ([@name_input, @email_input].all? {|input| input.check_validity })
            @table.content {
              tr {
                td { @name_input.value }
                td { @email_input.value }
              }
            }
            @email_input.value = @name_input.value = ''
          else
            error_messages = []
            error_messages << "Name is not valid! Make sure it is filled." if !@name_input.check_validity
            error_messages << "Email is not valid! Make sure it is filled and has a valid format." if !@email_input.check_validity
            $$.alert(error_messages.join("\n"))
          end
        end
      }
    }
    h1('Contacts Table')
    @table = table {
      tr {
        th('Name')
        th('Email')
      }
      tr {
        td('John Doe')
        td('johndoe@example.com')
      }
      tr {
        td('Jane Doe')
        td('janedoe@example.com')
      }
    }
    
    # CSS Styles
    style {
      <<~CSS
        .field-row {
          margin: 10px 5px;
        }
        .field {
          margin-left: 5px;
        }
        .submit-button {
          display: block;
          margin: 10px 5px;
        }
        table {
          border:1px solid grey;
          border-spacing: 0;
        }
        table tr td, table tr th {
          padding: 5px;
        }
        table tr:nth-child(even) {
          background: #ccc;
        }
      CSS
    }
  }.render
end
