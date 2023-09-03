# Copyright (c) 2020-2022 Andy Maleh
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

require 'glimmer/swt/widget_proxy'
require 'glimmer/swt/display_proxy'

module Glimmer
  module SWT
    class MessageBoxProxy < WidgetProxy
      STYLE = <<~CSS
        .message-box {
          position: fixed;
          z-index: 1000;
          padding-top: 100px;
          left: 0;
          top: 0;
          width: 100%;
          height: 100%;
          overflow: auto;
          background-color: rgb(0,0,0);
          background-color: rgba(0,0,0,0.4);
          text-align: center;
        }
        .message-box-content .text {
          background: rgb(80, 116, 211);
          color: white;
          padding: 5px;
        }
        .message-box-content .message {
          padding: 20px;
        }
        .message-box-content {
          background-color: #fefefe;
          padding-bottom: 15px;
          border: 1px solid #888;
          display: inline-block;
          min-width: 200px;
        }
      CSS
#         .close {
#           color: #aaaaaa;
#           float: right;
#           font-weight: bold;
#           margin: 5px;
#         }
#         .close:hover,
#         .close:focus {
#           color: #000;
#           text-decoration: none;
#           cursor: pointer;
#         }
      
      attr_reader :text, :message
      
      def initialize(parent, args, block)
        i = 0
        @parent = parent
        @parent = nil if parent.is_a?(LatestShellProxy)
        @parent ||= DisplayProxy.instance.shells.detect(&:open?) || ShellProxy.new([])
        @args = args
        @block = block
        @children = Set.new
        @enabled = true
        on_widget_selected {
          hide
        }
        DisplayProxy.instance.message_boxes << self
      end
      
      def text=(txt)
        @text = txt
        dom_element.find('.message-box-content .text').html(@text)
      end
    
      def html_message
        message&.gsub("\n", '<br />')
      end
      
      def message=(msg)
        @message = msg
        dom_element.find('.message-box-content .message').html(html_message)
      end
      
      def open?
        @open
      end
      
      def open
        shell.open(async: false) unless shell.open?
        owned_proc = Glimmer::Util::ProcTracker.new(owner: self, invoked_from: :open) {
          parent.post_initialize_child(self)
          @open = true
        }
        DisplayProxy.instance.async_exec(owned_proc)
      end
      
      def hide
        dom_element.remove
        @open = false
      end
      
      def content(&block)
        Glimmer::DSL::Engine.add_content(self, Glimmer::DSL::Opal::MessageBoxExpression.new, 'message_box', *@args, &block)
      end
      
      def selector
        super + ' .close'
      end
    
      def listener_path
        path + ' .close'
      end
    
      def observation_request_to_event_mapping
        {
          'on_widget_selected' => {
            event: 'click'
          },
        }
      end
 
      def dom
        @dom ||= html {
          div(id: id, class: "modal #{name}") {
            div(class: 'message-box-content') {
              header(class: 'text') {
                "#{text}&nbsp;" # ensure title area occuppied when there is no text by adding non-breaking space (&nbsp;)
              }
              tag(_name: 'p', id: 'message', class: 'message') {
                html_message
              }
              input(type: 'button', class: 'close', autofocus: 'autofocus', value: 'OK')
            }
          }
        }.to_s
      end
    end
  end
end

require 'glimmer/dsl/opal/message_box_expression'
