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

require 'net/http'

class File
  class << self
    REGEXP_DIR_FILE = /\(dir\)|\(file\)/
    
    attr_accessor :image_paths
    
    def read(*args, &block)
      # TODO implement via asset downloads in the future
      # No Op in Opal
    end
    
    # Include special processing for images that matches them against a list of available image paths from the server
    # to convert to web paths.
    alias expand_path_without_glimmer expand_path
    def expand_path(path, base=nil)
      get_image_paths unless image_paths
      path = expand_path_without_glimmer(path, base) if base
      path_include_dir_or_file = !!path.match(REGEXP_DIR_FILE)
      essential_path = path.split('(dir)').last.split('(file)').last.split('../').last.split('./').last
      image_paths.detect do |image_path|
        image_path.include?(essential_path)
      end
    end
    
    def get_image_paths
      image_paths_json = Net::HTTP.get(`window.location.origin`, "/glimmer/image_paths.json")
      self.image_paths = JSON.parse(image_paths_json)
    end
    
  end
end
