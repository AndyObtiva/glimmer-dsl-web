# Copyright (c) 2023-2026 Andy Maleh
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

# TODO consider extracting this class into its own Ruby gem
require 'delegate'

module Glimmer
  module Util
    class UrlQueryStringBuilder
      class << self
        def current
          new.query($$.document.location.search) if RUBY_ENGINE == 'opal'
        end
      end
    
      def initialize
        @params = {}
      end
      
      def with_question_mark
        @with_question_mark = true
        self
      end
      alias with_prefix with_question_mark
    
      def param(name, value)
        @params[name.to_s] = value
        self
      end
      
      def params(params_hash)
        @params = @params.merge(params_hash)
        self
      end
      
      def query(value)
        return self if value.nil?
        
        value = value.sub('?', '') if value.start_with?('?')
        value.split('&').each do |param_pair|
          name, value = param_pair.split('=')
          @params[name.to_s] = value
        end
        self
      end
      
      def to_query_string
        computed_query = @params.reject { |name, value| value.nil? || value.to_s.empty? }.map { |name, value| "#{name}=#{value}" }.join('&')
        computed_query = "?#{computed_query}" if @with_question_mark && !computed_query.empty?
        computed_query
      end
      alias to_s to_query_string
      alias build to_query_string
    end
  end
end
