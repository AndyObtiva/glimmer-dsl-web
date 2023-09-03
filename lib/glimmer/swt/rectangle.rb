module Glimmer
  module SWT
    # emulating org.eclipse.swt.graphics.Rectangle
    Rectangle = Struct.new(:x, :y, :width, :height)
    # TODO alias as org.eclipse.swt.graphics.Rectangle
  end
end
