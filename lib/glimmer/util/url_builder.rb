# TODO consider extracting this class into its own Ruby gem
require 'delegate'

require 'glimmer/util/url_query_string_builder'

module Glimmer
  module Util
    class UrlBuilder
      DEFAULT_SCHEME = 'https'
      REGEXP_URL = /^(https?)?(:\/\/)?(([^\/\:]+):?(\d+)?)?(\/[^?#]*)?(\?[^#]*)?(\#.+)?$/
      
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
        UrlQueryStringBuilder.new.with_prefix.params(@params).to_s
      end
    end
  end
end
