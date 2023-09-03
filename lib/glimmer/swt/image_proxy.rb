module Glimmer
  module SWT
    # emulating org.eclipse.swt.graphics.Image
    class ImageProxy
      class << self
        def create(*args, &content)
          if args.size == 1 && args.first.is_a?(ImageProxy)
            args.first
          else
            new(*args, &content)
          end
        end
      end
    
      attr_reader :file_path, :width, :height
      
      def initialize(*args)
        options = args.last.is_a?(Hash) ? args.last : {}
        # TODO support a parent as a first argument before the file path
        @file_path = args.first
        @width = options[:width]
        @height = options[:height]
      end
      
      # TODO implement scale_to
    end
    # TODO alias as org.eclipse.swt.graphics.Image
  end
end
