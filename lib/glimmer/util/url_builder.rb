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
    class UrlBuilder
      DEFAULT_SCHEME = 'https'
      REGEXP_URL = /^(http|https)?(:\/\/)?(([^\/\:]+):?(\d+)?)?(\/[^?#]*)?(\?[^#]*)?(\#.+)?$/
      
      class << self
        def current
          new.url($$.document.location.href) if RUBY_ENGINE == 'opal'
        end
      end
    
      def initialize
        @scheme = DEFAULT_SCHEME
        @params = {}
      end
    
      def scheme(value)
        @scheme = value || DEFAULT_SCHEME
        @scheme = @scheme.gsub(/[:\/]/, '')
        self
      end
      alias protocol scheme
      
      def host(value)
        return self if value.nil?
        
        @host = value
        @host.gsub('/', '')
        self
      end
      
      def port(value)
        return self if value.nil?
        
        @port = value
        self
      end
      
      def path(value)
        return self if value.nil?
        
        @path = value
        @path = "/#{@path}" unless @path.start_with?('/')
        self
      end
      
      def param(name, value)
        @params[name.to_s] = value
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
      
      def fragment(value)
        return self if value.nil?
        
        @fragment = value
        @fragment = "##{@fragment}" unless @fragment.start_with?('#')
        self
      end
      
      def url(value)
        url_scheme, url_slashes, url_host_port, url_host, url_port, url_path, url_query, url_fragment = REGEXP_URL.match(value).to_a.drop(1)
        scheme(url_scheme).host(url_host).port(url_port).path(url_path).query(url_query).fragment(url_fragment)
      end
      
      def to_url
        output = "#{@scheme}://#{@host}"
        output += ":#{@port}" if @port
        output += "#{@path&.strip}#{compute_query}#{@fragment&.strip}"
        output
      end
      alias to_s to_url
      alias build to_url
      
      def compute_query
        computed_query = @params.reject { |name, value| value.nil? || value.to_s.empty? }.map { |name, value| "#{name}=#{value}" }.join('&')
        computed_query = "?#{computed_query}" unless computed_query.empty?
        computed_query
      end
    end
  end
end
