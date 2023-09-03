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

require 'glimmer/ui/custom_widget'

module Glimmer
  module SWT
    module Custom
      # A custom widget rendering a group of radios generated via data-binding
      class RadioGroup
        include Glimmer::UI::CustomWidget
        
        body {
          composite # just an empty composite to hold radios upon data-binding `selection`
        }
        
        def items=(text_array)
          selection_value = selection
          @items = Array[*text_array]
          build_radios
        end
        
        def items
          @items || []
        end
        
        def selection=(text)
          radios.count.times do |index|
            radio = radios[index]
            item = items[index]
            radio.selection = item == text
          end
        end
        
        def selection
          selection_value = radios[selection_index]&.text unless selection_index == -1
          selection_value.to_s
        end
        
        def selection_index=(index)
          self.selection=(items[index])
        end
        alias select selection_index=
        
        def selection_index
          radios.index(radios.detect(&:selection)) || -1
        end
        
        def radios
          @radios ||= []
        end
        
        def observation_request_to_event_mapping
          # TODO method might not be needed
          {
            'on_widget_selected' => {
              event: 'change'
            },
          }
        end
        
        def can_handle_observation_request?(observation_request)
          radios.first&.can_handle_observation_request?(observation_request) || super(observation_request)
        end
        
        def handle_observation_request(observation_request, block)
          observation_requests << [observation_request, block]
          delegate_observation_request_to_radios(observation_request, &block)
          super
        end
        
        def delegate_observation_request_to_radios(observation_request, &block)
          if observation_request != 'on_widget_disposed'
            radios.count.times do |index|
            radio = radios[index]
            radio.handle_observation_request(observation_request, block) if radio.can_handle_observation_request?(observation_request)
            end
          end
        end
        
        def observation_requests
          @observation_requests ||= Set.new
        end
        
        def has_attribute?(attribute_name, *args)
          @radios.to_a.map do |widget_proxy|
            return true if widget_proxy.has_attribute?(attribute_name, *args)
          end
          super
        end
         
        def set_attribute(attribute_name, *args)
          excluded_attributes = ['selection']
          unless excluded_attributes.include?(attribute_name.to_s)
            @radios.to_a.each do |widget_proxy|
              widget_proxy.set_attribute(attribute_name, *args) if widget_proxy.has_attribute?(attribute_name, *args)
            end
          end
          super
        end
        
        private
        
        def build_radios
          current_selection = selection
          @radios = []
          items.each do |item|
            body_root.content {
              radios << radio { |radio_proxy|
                text item
                on_widget_selected {
                  self.selection = items[radios.index(radio_proxy)]
                }
              }
            }
          end
          observation_requests.to_a.each do |observation_request, block|
            delegate_observation_request_to_radios(observation_request, &block)
          end
          self.selection = current_selection
        end
      end
    end
  end
end
