module Rails
  # ResourceService supports index/show/create/update/destroy REST API calls for any Rails resources
  # Automatically loads the authenticity token from meta[name=csrf-token] content attribute
  # Assumes a resource or resource class that matches the name of a Backend ActiveRecord Model (e.g. Contact class or instance)
  class ResourceService
    TIMESTAMP_ATTRIBUTES = ['created_at', 'updated_at']
    
    class << self
      def index(resource: nil, resource_class: nil, singular_resource_name: nil, plural_resource_name: nil, index_resource_url: nil, params: nil, &response_handler)
        resource_class ||= resource&.class
        singular_resource_name ||= singular_resource_name_for_resource_class(resource_class)
        plural_resource_name ||= "#{singular_resource_name}s"
        index_resource_url ||= "/#{plural_resource_name}.json"
        HTTP.get(index_resource_url, payload: index_show_destroy_resource_params(params: params.to_h)) do |response|
          if response.ok? && !resource_class.nil?
            resource_response_objects = Native(response.body)
            resources = resource_response_objects.map { |resource_response_object| build_resource_from_response_object(resource_class:, resource_response_object:) }
          end
          response_handler.call(response, resources)
        end
      end
      
      def show(resource: nil, resource_class: nil, resource_id: nil, singular_resource_name: nil, plural_resource_name: nil, show_resource_url: nil, params: nil, &response_handler)
        resource_class ||= resource&.class
        resource_id ||= resource&.id
        singular_resource_name ||= singular_resource_name_for_resource_class(resource_class)
        plural_resource_name ||= "#{singular_resource_name}s"
        show_resource_url ||= "/#{plural_resource_name}/#{resource_id}.json"
        HTTP.get(show_resource_url, payload: index_show_destroy_resource_params(params: params.to_h)) do |response|
          if response.ok? && !resource_class.nil?
            resource_response_object = Native(response.body)
            resource = build_resource_from_response_object(resource_class:, resource_response_object:)
          end
          response_handler.call(response, resource)
        end
      end
      
      def create(resource: nil, resource_class: nil, resource_attributes: nil, singular_resource_name: nil, plural_resource_name: nil, create_resource_url: nil, params: nil, &response_handler)
        resource_class ||= resource&.class
        singular_resource_name ||= singular_resource_name_for_resource_class(resource_class)
        plural_resource_name ||= "#{singular_resource_name}s"
        create_resource_url ||= "/#{plural_resource_name}.json"
        HTTP.post(create_resource_url, payload: create_update_resource_params(resource:, resource_class:, resource_attributes:, singular_resource_name:, params: params.to_h)) do |response|
          if response.ok?
            if !resource_class.nil?
              resource_response_object = Native(response.body)
              resource = build_resource_from_response_object(resource_class:, resource_response_object:)
            end
          else
            errors = JSON.parse(response.body)
          end
          response_handler.call(response, resource, errors)
        end
      end
      
      def update(resource: nil, resource_class: nil, resource_id: nil, resource_attributes: nil, singular_resource_name: nil, plural_resource_name: nil, update_resource_url: nil, params: nil, &response_handler)
        resource_class ||= resource&.class
        resource_id ||= resource&.id
        singular_resource_name ||= singular_resource_name_for_resource_class(resource_class)
        plural_resource_name ||= "#{singular_resource_name}s"
        update_resource_url ||= "/#{plural_resource_name}/#{resource_id}.json"
        HTTP.patch(update_resource_url, payload: create_update_resource_params(resource:, resource_class:, resource_attributes:, singular_resource_name:, params: params.to_h)) do |response|
          if response.ok?
            if !resource_class.nil?
              resource_response_object = Native(response.body)
              resource = build_resource_from_response_object(resource_class:, resource_response_object:)
            end
          else
            errors = JSON.parse(response.body)
          end
          response_handler.call(response, resource, errors)
        end
      end
      
      def destroy(resource: nil, resource_class: nil, resource_id: nil, singular_resource_name: nil, plural_resource_name: nil, destroy_resource_url: nil, params: nil, &response_handler)
        resource_class ||= resource&.class
        resource_id ||= resource&.id
        singular_resource_name ||= singular_resource_name_for_resource_class(resource_class)
        plural_resource_name ||= "#{singular_resource_name}s"
        destroy_resource_url ||= "/#{plural_resource_name}/#{resource_id}.json"
        HTTP.delete(destroy_resource_url, payload: index_show_destroy_resource_params(params: params.to_h), &response_handler)
      end
      
      def index_show_destroy_resource_params(params: nil)
        {authenticity_token:}.merge(params.to_h)
      end
      
      def create_update_resource_params(resource: nil, resource_class: nil, resource_attributes: nil, singular_resource_name: nil, params: nil)
        resource_class ||= resource&.class
        singular_resource_name ||= singular_resource_name_for_resource_class(resource_class)
        resource_params = {authenticity_token:}
        resource_attributes ||= resource&.to_h&.reject { |attribute, value| TIMESTAMP_ATTRIBUTES.include?(attribute) }
        resource_params[singular_resource_name] = resource_attributes.to_h
        resource_params = resource_params.merge(params.to_h)
        resource_params
      end
      
      def authenticity_token
        Element['meta[name=csrf-token]'].attr('content')
      end
      
      def singular_resource_name_for_resource_class(resource_class)
        return nil if resource_class.nil?
        resource_class.to_s.split('::').last.downcase
      end
      
      def build_resource_from_response_object(resource_class:, resource_response_object:)
        resource = resource_class.new
        resource_response_object.each { |attribute, value| resource.send("#{attribute}=", value) rescue nil }
        resource
      end
    end
  end
end
