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
    # Emulates SWT's native org.eclipse.swt.custom.ControlEditor
    class ControlEditor
      # TODO implement behavior for all these attributes
      ATTRIBUTES = [:grabHorizontal, :grabVertical, :horizontalAlignment, :verticalAlignment, :minimumWidth, :minimumHeight]
      attr_accessor(*ATTRIBUTES)
      ATTRIBUTES.each do |attribute|
        alias_method attribute.to_s.underscore, attribute
        alias_method "#{attribute.to_s.underscore}=", "#{attribute}="
      end
      
      # TODO consider supporting a java_attr_accessor to get around having to generate all the aliases manually
      attr_accessor :editor
      alias getEditor editor
      alias get_editor editor
      alias setEditor editor=
      alias set_editor editor=
      
      # TODO implement `#layout` method if needed
      
      attr_reader :composite
      
      def initialize(composite)
        @composite = composite
      end
      
      # TODO implement showing editor for composite or canvas
#       def editor=(widget)
#       end
    end
  end
end
