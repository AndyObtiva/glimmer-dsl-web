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

require 'glimmer/swt/property_owner'

module Glimmer
  module SWT
    class LayoutProxy
      include Glimmer::SWT::PropertyOwner
      
      class << self
        # Factory Method that translates a Glimmer DSL keyword into a WidgetProxy object
        def for(keyword, parent, args)
          the_layout_class = layout_class(keyword) || Glimmer::SWT::GridLayoutProxy
          the_layout_class.new(parent, args)
        end
        
        def layout_class(keyword)
          class_name_main = "#{keyword.camelcase(:upper)}Proxy"
          a_layout_class = Glimmer::SWT.const_get(class_name_main.to_sym)
          a_layout_class if a_layout_class.ancestors.include?(Glimmer::SWT::LayoutProxy)
        rescue => e
          Glimmer::Config.logger.debug "Layout #{keyword} was not found!"
          nil
        end
        
        def layout_exists?(keyword)
          !!layout_class(keyword)
        end
      end
      
      attr_reader :parent, :args
        
      def initialize(parent, args)
        @parent = parent
        @args = args
        @parent = parent.body_root if @parent.is_a?(Glimmer::UI::CustomWidget)
        @parent.css_classes.each do |css_class|
          @parent.remove_css_class(css_class) if css_class.include?('layout')
        end
        @parent.add_css_class(css_class)
        @parent.layout = self
        self.margin_width = 15 if respond_to?(:margin_width=)
        self.margin_height = 15 if respond_to?(:margin_height=)
      end
              
      def layout​(composite = nil, flush_cache = false)
        # TODO implement def layout​(composite = nil, flush_cache = false) as per SWT API
        composite ||= @parent
        initialize(composite, @args)
      end
      
      def css_class
        self.class.name.split('::').last.underscore.sub(/_proxy$/, '').gsub('_', '-')
      end
      
      # Decorates widget dom. Subclasses may override. Returns widget dom by default.
      def dom(widget_dom)
        widget_dom
      end
      
    end
  end
end

require 'glimmer/swt/grid_layout_proxy'
require 'glimmer/swt/fill_layout_proxy'
require 'glimmer/swt/row_layout_proxy'
