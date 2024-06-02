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

require_relative 'todo_mvc/presenters/todo_presenter'

require_relative 'todo_mvc/views/new_todo_form'
require_relative 'todo_mvc/views/todo_list'
require_relative 'todo_mvc/views/todo_filters'

class TodoMvc
  include Glimmer::Web::Component
  
  before_render do
    @presenter = TodoPresenter.new
  end
  
  markup {
    section(class: 'todoapp') {
      new_todo_form(presenter: @presenter)
      
      todo_list(presenter: @presenter)
      
      todo_filters(presenter: @presenter)
            
      style {
        rule('body, button, html') {
          margin '0'
          padding '0'
        }
        
        rule('.todoapp') {
          background '#fff'
          margin '130px 0 40px 0'
          position 'relative'
          box_shadow '0 2px 4px 0 rgba(0, 0, 0, 0.2), 0 25px 50px 0 rgba(0, 0, 0, 0.1)'
        }
      
        media('screen and (-webkit-min-device-pixel-ratio:0)') {
          rule('body') {
            font "14px 'Helvetica Neue', Helvetica, Arial, sans-serif"
            line_height '1.4em'
            background '#f5f5f5'
            color '#111111'
            min_width '230px'
            max_width '550px'
            margin '0 auto'
            smoothing 'grayscale'
            font_weight '300'
          }
        }
      }
    }
  }
end

Document.ready? do
  TodoMvc.render
end
