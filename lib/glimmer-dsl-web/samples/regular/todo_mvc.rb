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

class TodoMvc
  include Glimmer::Web::Component
  
  before_render do
  end
  
  markup {
    section(class: 'todoapp') {
      header(class: 'header') {
        h1('todos')
        input(class: "new-todo", placeholder: "What needs to be done?", autofocus: "")
      }
#             <main class="main" style="display: block;">
#                 <div class="toggle-all-container">
#                     <input class="toggle-all" type="checkbox">
#                     <label class="toggle-all-label" for="toggle-all">Mark all as complete</label>
#                 </div>
#                 <ul class="todo-list"><li data-id="1" class=""><div class="view"><input class="toggle" type="checkbox"><label>coffee</label><button class="destroy"></button></div></li></ul>
#             </main>
#             <footer class="footer" style="display: block;">
#                 <span class="todo-count"><strong>1</strong> item left</span>
#                 <ul class="filters">
#                     <li>
#                         <a href="#/" class="selected">All</a>
#                     </li>
#                     <li>
#                         <a href="#/active">Active</a>
#                     </li>
#                     <li>
#                         <a href="#/completed">Completed</a>
#                     </li>
#                 </ul>
#                 <button class="clear-completed" style="display: none;"></button>
#             </footer>
      
      style {
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
        
        rule('.todoapp') {
          background '#fff'
          margin '130px 0 40px 0'
          position 'relative'
          box_shadow '0 2px 4px 0 rgba(0, 0, 0, 0.2), 0 25px 50px 0 rgba(0, 0, 0, 0.1)'
        }
                
        rule('.header h1') {
          width '100%'
          font_size '80px'
          line_height '80px'
          margin '0'
          font_weight '200'
          text_align 'center'
          color '#b83f45'
          text_rendering 'optimizeLegibility'
        }
        
        rule('.new-todo') {
          padding '16px 16px 16px 60px'
          height '65px'
          border 'none'
          background 'rgba(0, 0, 0, 0.003)'
          box_shadow 'inset 0 -2px 1px rgba(0,0,0,0.03)'
        }

        rule('.new-todo, .edit') {
          position 'relative'
          margin '0'
          width '100%'
          font_size '24px'
          font_family 'inherit'
          font_weight 'inherit'
          line_height '1.4em'
          color 'inherit'
          padding '6px'
          border '1px solid #999'
          box_shadow 'inset 0 -1px 5px 0 rgba(0, 0, 0, 0.2)'
          box_sizing 'border-box'
          smoothing 'antialiased'
        }
      }
    }
  }
end

Document.ready? do
  TodoMvc.render
end
