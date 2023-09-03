module Glimmer
  # Consumer Rails apps can set these attributes in their assets.rb file
  module Config
    class << self
      # (server-side option) used to collect image paths for copying to assets & matching in Opal to download and use in Glimmer GUI
      def gems_having_image_paths
        @gems_having_image_paths ||= []
      end
    end
  end
end
