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
require 'glimmer/swt/layout_proxy'
require 'glimmer/swt/display_proxy'
require 'glimmer/swt/point'

module Glimmer
  module SWT
    class ShellProxy < CompositeProxy
      STYLE = <<~CSS
        html {
          width: 100%;
          height: 100%;
        }
        body {
          width: 100%;
          height: 100%;
          margin: 0;
        }
        * {
          cursor: inherit;
        }
        .shell {
          height: 100%;
          margin: 0;
        }
        .shell iframe {
          width: 100%;
          height: 100%;
        }
        .shell .dialog-overlay {
          position: fixed;
          z-index: 10;
          padding-top: 100px;
          left: 0;
          top: 0;
          width: 100%;
          height: 100%;
          overflow: auto;
          background-color: rgba(0,0,0,0.4);
        }
      CSS
    
      # TODO consider renaming to ShellProxy to match SWT API
      attr_reader :minimum_size
      attr_accessor :menu_bar
    
      WIDTH_MIN = 130
      HEIGHT_MIN = 0
      
      def initialize(args)
        # TODO set parent
        @args = args
        @children = []
        render # TODO attach to specific element
        @layout = FillLayoutProxy.new(self, [])
        @layout.margin_width = 0
        @layout.margin_height = 0
        self.minimum_size = Point.new(WIDTH_MIN, HEIGHT_MIN)
        DisplayProxy.instance.shells << self
      end
              
      def post_add_content
        `$( document ).tooltip()`
      end
      
      def element
        'div'
      end
      
      def parent_path
        'body'
      end

      def text
        $document.title
      end

      def text=(value)
        Document.title = value
      end
      
      # favicon
      def image
        @image
      end
      
      def image=(value)
        @image = value
        # TODO consider moving this code to favicon_dom_element
        if favicon_dom_element.empty?
          favicon_element = Element.new(:link)
          favicon_element.attr('rel', 'icon')
          Document.find('head').append(favicon_element)
        else
          favicon_element = favicon_dom_element
        end
        favicon_element.attr('href', image)
      end
      
      def favicon_dom_element
        Document.find('link[rel=icon]')
      end
      
      def minimum_size=(width_or_minimum_size, height = nil)
        @minimum_size = height.nil? ? width_or_minimum_size : Point.new(width_or_minimum_size, height)
        return if @minimum_size.nil?
        dom_element.css('min-width', "#{@minimum_size.x}px")
        dom_element.css('min-height', "#{@minimum_size.y}px")
      end
      
      def handle_observation_request(keyword, original_event_listener)
        case keyword
        when 'on_swt_show', 'on_swt_close', 'on_shell_closed'
          keyword = 'on_swt_close' if keyword == 'on_shell_closed'
          listeners_for(keyword.sub(/^on_/, '')) << original_event_listener.to_proc
        else
          super(keyword, original_event_listener)
        end
      end
      
      def style_dom_css
        <<~CSS
          .hide {
            display: none !important;
          }
          .selected {
            background: rgb(80, 116, 211);
            color: white;
          }
        CSS
      end
            
      def dom
        i = 0
        body_id = id
        body_class = ([name, 'hide'] + css_classes.to_a).join(' ')
        @dom ||= html {
          div(id: body_id, class: body_class) {
            # TODO consider supporting the idea of dynamic CSS building on close of shell that adds only as much CSS as needed for widgets that were mentioned
            style(class: 'common-style') {
              style_dom_css
            }
            [LayoutProxy, WidgetProxy].map(&:descendants).reduce(:+).each do |style_class|
              if style_class.constants.include?('STYLE')
                style(class: "#{style_class.name.split(':').last.underscore.gsub('_', '-').sub(/-proxy$/, '')}-style") {
                  style_class::STYLE
                }
              end
            end
            div(class: 'dialog-overlay hide') {
            }
          }
        }.to_s
      end
      
      def open(async: true)
        work = lambda do
          unless @open
            DisplayProxy.instance.shells.select(&:open?).reject {|s| s == self}.map(&:hide)
            dom_element.remove_class('hide')
            @open = true
            listeners_for('swt_show').each {|listener| listener.call(Event.new(widget: self))}
          end
        end
        if async
          DisplayProxy.instance.async_exec(&work)
        else
          work.call
        end
      end
      alias show open
      
      def hide
        dom_element.add_class('hide')
        @open = false
      end
      
      def close
        DisplayProxy.instance.shells.delete(self)
        dom_element.remove
        @open = false
        listeners_for('swt_close').each {|listener| listener.call(Event.new(widget: self))}
      end
      
      def open?
        @open
      end
      
      def visible
        @open
      end
      alias visible? visible
      
      def visible=(value)
        if value
          show(async: false)
        else
          hide
        end
      end
    end
  end
end
