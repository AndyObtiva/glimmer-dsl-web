require 'opal'

GLIMMER_DSL_WEB_ROOT = File.expand_path('../..', __FILE__)
GLIMMER_DSL_WEB_LIB = File.join(GLIMMER_DSL_WEB_ROOT, 'lib')
 
$LOAD_PATH.unshift(GLIMMER_DSL_WEB_LIB)

if RUBY_ENGINE != 'opal'
  require 'opal-rails'
  require 'opal-async'
  require 'opal-jquery'
  require 'glimmer/helpers/glimmer_helper'
else
#   GLIMMER_DSL_WEB_MISSING = File.join(GLIMMER_DSL_WEB_ROOT, 'lib', 'glimmer-dsl-opal', 'missing')
   
#   $LOAD_PATH.unshift(GLIMMER_DSL_WEB_MISSING) # missing Ruby classes/methods
  # TODO look into making append_path work (causing some trouble right now)
#   Opal.append_path File.expand_path('../glimmer-dsl-opal/missing', __FILE__)
#   Opal.append_path GLIMMER_DSL_WEB_MISSING
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
  require 'glimmer-dsl-web/ext/kernel'
  
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
  require 'glimmer-dsl-css'
  
  Glimmer::Config.loop_max_count = 50 # TODO consider disabling if preferred
  
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
  require 'glimmer/web/component/page_component_link'
  require 'glimmer/web/component/page_component_button'
  require 'glimmer/web/component/back_link'
end
