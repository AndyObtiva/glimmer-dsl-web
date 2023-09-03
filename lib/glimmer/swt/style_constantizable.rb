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

require 'glimmer/error'

module Glimmer
  module SWT
    # Mixin for all proxy classes that manage style constants (e.g. SWT, DND, etc...)
    module StyleConstantizable
      module ClassMethods
        REGEX_SYMBOL_NEGATIVITY = /^([^!]+)(!)?$/
      
        def constant_source_class
          raise 'Not implemented! Mixer must implement!'
        end
 
        def constant_value_none
          # TODO instead of raising error try a convention instead like CLASSNAME::NONE by default
          raise 'Not implemented! Mixer must implement!'
        end
        
        # hash of extra styles (i.e. new style combinations)
        def extra_styles
          raise 'Not implemented! Mixer must implement!'
        end
                
        def error_message_invalid_style
          " is an invalid #{constant_source_class.name.split(':').last} style! Please choose a style from #{constant_source_class.name} class constants." # TODO parameterize
        end

        # Gets constants (e.g. SWT::CONSTANT) where constant is
        # passed in as a lower case symbol
        def [](*symbols)
          symbols = symbols.first if symbols.size == 1 && symbols.first.is_a?(Array)
          result = symbols.compact.map do |symbol|
            constant(symbol).tap do |constant_value|
              raise Glimmer::Error, symbol.to_s + error_message_invalid_style unless constant_value.is_a?(Integer)
            end
          end.reduce do |output, constant_value|
            if constant_value < 0
              output & constant_value
            else
              output | constant_value
            end
          end
          result.nil? ? constant_value_none : result
        end

        # Returns style integer value for passed in symbol or allows
        # passed in object to pass through (e.g. Integer). This makes is convenient
        # to use symbols or actual style integers in Glimmer
        # Does not raise error for invalid values. Just lets them pass as is.
        # (look into [] operator if you want an error raised on invalid values)
        def constant(symbol)
          return symbol unless symbol.is_a?(Symbol) || symbol.is_a?(String)
          symbol_string, negative = extract_symbol_string_negativity(symbol)
          swt_constant_symbol = symbol_string.downcase == symbol_string ? symbol_string.upcase.to_sym : symbol_string.to_sym
          bit_value = constant_source_class.const_get(swt_constant_symbol)
          negative ? ~bit_value : bit_value
        rescue => e
          begin
#             Glimmer::Config.logger.debug {e.full_message}
            alternative_swt_constant_symbol = constant_source_class.constants.find {|c| c.to_s.upcase == swt_constant_symbol.to_s.upcase}
            bit_value = constant_source_class.const_get(alternative_swt_constant_symbol)
            negative ? ~bit_value : bit_value
          rescue => e
#             Glimmer::Config.logger.debug {e.full_message}
            bit_value = extra_styles[swt_constant_symbol]
            if bit_value
              negative ? ~bit_value : bit_value
            else
              symbol
            end
          end
        end
        
        def extract_symbol_string_negativity(symbol)
          if symbol.is_a?(Symbol) || symbol.is_a?(String)
            symbol_negativity_match = symbol.to_s.match(REGEX_SYMBOL_NEGATIVITY)
            symbol = symbol_negativity_match[1]
            negative = !!symbol_negativity_match[2]
            [symbol, negative]
          else
            negative = symbol < 0
            [symbol, negative]
          end
         end

        def negative?(symbol)
          extract_symbol_string_negativity(symbol)[1]
        end

        def has_constant?(symbol)
          return false unless symbol.is_a?(Symbol) || symbol.is_a?(String)
          constant(symbol).is_a?(Integer)
        end

        def constantify_args(args)
          args.map {|arg| constant(arg)}
        end

        # Deconstructs a style integer into symbols
        # Useful for debugging
        def deconstruct(integer)
          constant_source_class.constants.reduce([]) do |found, c|
            constant_value = constant_source_class.const_get(c) rescue -1
            is_found = constant_value.is_a?(Integer) && (integer & constant_value) == integer
            is_found ? found += [c] : found
          end
        end

        # Reverse engineer a style integer into a symbol
        # Useful for debugging
        def reverse_lookup(integer)
          constant_source_class.constants.reduce([]) do |found, c|
            constant_value = constant_source_class.const_get(c) rescue -1
            is_found = constant_value.is_a?(Integer) && integer == constant_value
            is_found ? found += [c] : found
          end
        end

        def include?(swt_constant, *symbols)
          swt_constant & self[symbols] == self[symbols]
        end
        
      end
      
      def self.included(klass)
        klass.extend(ClassMethods)
      end
      
    end
    
  end
  
end
