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
