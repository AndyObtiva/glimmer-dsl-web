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

module Glimmer
  module SWT
    # Proxy for org.eclipse.swt.graphics.Color
    #
    # Invoking `#swt_color` returns the SWT Color object wrapped by this proxy
    #
    # Follows the Proxy Design Pattern
    class ColorProxy
      SWT_COLOR_TRANSLATION = {
        "widget_foreground"                   => [0, 0, 0],
        "blue"                                => [0, 0, 255],
        "widget_dark_shadow"                  => [0, 0, 0],
        "title_foreground"                    => [0, 0, 0],
        "yellow"                              => [255, 255, 0],
        "widget_highlight_shadow"             => [255, 255, 255],
        "dark_cyan"                           => [0, 128, 128],
        "list_foreground"                     => [0, 0, 0],
        "dark_blue"                           => [0, 0, 128],
        "dark_yellow"                         => [128, 128, 0],
        "cyan"                                => [0, 255, 255],
        "info_background"                     => [236, 235, 236],
        "link_foreground"                     => [0, 104, 218],
        "title_inactive_foreground"           => [0, 0, 0],
        "title_background_gradient"           => [179, 215, 255],
        "red"                                 => [255, 0, 0],
        "title_inactive_background_gradient"  => [220, 220, 220],
        "transparent"                         => [255, 255, 255],
        "widget_light_shadow"                 => [232, 232, 232],
        "dark_magenta"                        => [128, 0, 128],
        "white"                               => [255, 255, 255],
        "list_selection"                      => [179, 215, 255],
        "gray"                                => [192, 192, 192],
        "widget_border"                       => [0, 0, 0],
        "widget_background"                   => [236, 236, 236],
        "info_foreground"                     => [0, 0, 0],
        "title_inactive_background"           => [220, 220, 220],
        "widget_disabled_foreground"          => [220, 220, 220],
        "list_background"                     => [255, 255, 255],
        "magenta"                             => [255, 0, 255],
        "title_background"                    => [0, 99, 225],
        "text_disabled_background"            => [255, 255, 255],
        "black"                               => [0, 0, 0],
        "dark_gray"                           => [128, 128, 128],
        "list_selection_text"                 => [0, 0, 0],
        "dark_red"                            => [128, 0, 0],
        "widget_normal_shadow"                => [159, 159, 159],
        "dark_green"                          => [0, 128, 0],
        "green"                               => [0, 255, 0]
      }
    
      attr_reader :args, :red, :green, :blue, :alpha
    
      # Initializes a proxy for an SWT Color object
      #
      # Takes a standard color single argument, rgba 3 args, or rgba 4 args
      #
      # A standard color is a string/symbol representing one of the
      # SWT.COLOR_*** constants like SWT.COLOR_RED, but in underscored string
      # format (e.g :color_red).
      # Glimmer can also accept standard color names without the color_ prefix,
      # and it will automatically figure out the SWT.COLOR_*** constant
      # (e.g. :red)
      #
      # rgb is 3 arguments representing Red, Green, Blue numeric values
      #
      # rgba is 4 arguments representing Red, Green, Blue, and Alpha numeric values
      #
      def initialize(*args)
        @args = args
        case @args.size
        when 1
          @alpha = nil
          if @args.first.is_a?(String) || @args.first.is_a?(Symbol)
            standard_color = @args.first.to_s.downcase.sub('COLOR_', '')
            @red, @green, @blue = SWT_COLOR_TRANSLATION[standard_color]
          else
            @red, @green, @blue = [0, 0, 0]
          end
        when 3..4
          @red, @green, @blue, @alpha = @args
        end
      end
      
      def to_css
        if alpha.nil?
          "rgb(#{red}, #{green}, #{blue})"
        else
          "rgba(#{red}, #{green}, #{blue}, #{alpha_css})"
        end
      end
      
      def alpha_css
        alpha.to_f / 255
      end

    end
  end
end
