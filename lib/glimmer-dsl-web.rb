# Copyright (c) 2023 Andy Maleh
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

require 'opal'

GLIMMER_DSL_OPAL_ROOT = File.expand_path('../..', __FILE__)
GLIMMER_DSL_OPAL_LIB = File.join(GLIMMER_DSL_OPAL_ROOT, 'lib')
 
$LOAD_PATH.unshift(GLIMMER_DSL_OPAL_LIB)

if RUBY_ENGINE == 'opal'
#   GLIMMER_DSL_OPAL_MISSING = File.join(GLIMMER_DSL_OPAL_ROOT, 'lib', 'glimmer-dsl-opal', 'missing')
   
#   $LOAD_PATH.unshift(GLIMMER_DSL_OPAL_MISSING) # missing Ruby classes/methods
  # TODO look into making append_path work (causing some trouble right now)
#   Opal.append_path File.expand_path('../glimmer-dsl-opal/missing', __FILE__)
#   Opal.append_path GLIMMER_DSL_OPAL_MISSING
  module Kernel
    def include_package(package)
      # No Op (just a shim)
    end
    
    def __dir__
      '(dir)'
    end
  end
  
  require 'opal-parser'
  require 'native' # move this to opal-async
  require 'opal-async'
  require 'async/ext'
  require 'to_collection'
  require 'glimmer-dsl-web/vendor/jquery'
  require 'opal-jquery'
  require 'opal/jquery/local_storage'
  require 'promise'
 
  require 'facets/hash/symbolize_keys'
  require 'facets/string/underscore'
  require 'glimmer-dsl-web/ext/class'
  require 'glimmer'
  require 'glimmer-dsl-web/ext/exception'
  require 'glimmer-dsl-web/ext/date'
  
  # Spiking async logging
#   logger = Glimmer::Config.logger
#   original_add_method = logger.class.instance_method(:add)
#   logger.define_singleton_method("__original_add", original_add_method)
#   logger.singleton_class.send(:define_method, :add) do |*args|
#     Async::Timeout.new 10000 do
#       __original_add(*args)
#     end
#   end
      
  require 'glimmer/dsl/web/dsl'
  require 'glimmer/config/opal_logger'
  require 'glimmer-dsl-xml'
  require 'glimmer-dsl-css'
  
  Glimmer::Config.loop_max_count = 150 # TODO consider disabling if preferred
  
  original_logger_level = Glimmer::Config.logger.level
  Glimmer::Config.logger = Glimmer::Config::OpalLogger.new(STDOUT)
  Glimmer::Config.logger.level = original_logger_level
  Glimmer::Config.excluded_keyword_checkers << lambda do |method_symbol, *args|
    method = method_symbol.to_s
    result = false
    result ||= method == '<<'
    result ||= method == 'handle'
  end
  
# else # TODO enable when ready to include a Rails engine in the gem
#   require_relative 'glimmer/config'
#   require_relative 'glimmer/engine'
end
