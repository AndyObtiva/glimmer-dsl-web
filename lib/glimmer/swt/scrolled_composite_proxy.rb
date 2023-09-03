require 'glimmer/swt/grid_layout_proxy'
require 'glimmer/swt/widget_proxy'

module Glimmer
  module SWT
    class ScrolledCompositeProxy < CompositeProxy
      STYLE = <<~CSS
        .scrolled-composite {
        }
      CSS
      
      # TODO set overflow-y and overflow-x based on :v_scroll and :h_scroll styles.... though consider also that it might not be needed in web browsers where scrollbars are always present
      #  height: 100px;
      #  overflow-y: auto;       
      
    end
    
  end
  
end
