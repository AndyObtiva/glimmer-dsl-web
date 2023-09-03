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
      # A custom widget rendering a group of checkboxes generated via data-binding
      class CheckboxGroup
        include Glimmer::UI::CustomWidget
        
        body {
          composite # just an empty composite to hold checkboxs upon data-binding `selection`
        }
        
        def items=(text_array)
          selection_value = selection
          @items = Array[*text_array]
          build_checkboxes
        end
        
        def items
          @items || []
        end
        
        def selection=(selection_texts)
          items.count.times do |index|
            checkbox = checkboxes[index]
            item = items[index]
            checkbox_text = checkbox&.text
            checkbox.selection = selection_texts.to_a.include?(checkbox_text)
          end
          selection_texts
        end
        
        def selection
          selection_indices.map do |selection_index|
            checkboxes[selection_index]&.text
          end
        end
        
        def selection_indices=(indices)
          self.selection=(indices.to_a.map {|index| items[index]})
        end
        alias select selection_indices=
        
        def selection_indices
          checkboxes.each_with_index.map do |checkbox, index|
            index if checkbox.selection
          end.to_a.compact
        end
        
        def checkboxes
          @checkboxes ||= []
        end
        alias checks checkboxes
        
        def can_handle_observation_request?(observation_request)
          checkboxes.first&.can_handle_observation_request?(observation_request) || super(observation_request)
        end
        
        def handle_observation_request(observation_request, block)
          observation_requests << [observation_request, block]
          delegate_observation_request_to_checkboxes(observation_request, &block)
          super
        end
        
        def delegate_observation_request_to_checkboxes(observation_request, &block)
          if observation_request != 'on_widget_disposed'
            checkboxes.count.times do |index|
              checkbox = checkboxes[index]
              checkbox.handle_observation_request(observation_request, block) if checkbox.can_handle_observation_request?(observation_request)
            end
          end
        end
        
        def observation_requests
          @observation_requests ||= Set.new
        end
        
        def has_attribute?(attribute_name, *args)
          @checkboxes.to_a.map do |widget_proxy|
            return true if widget_proxy.has_attribute?(attribute_name, *args)
          end
          super
        end
         
        def set_attribute(attribute_name, *args)
          excluded_attributes = ['selection']
          unless excluded_attributes.include?(attribute_name.to_s)
            @checkboxes.to_a.each do |widget_proxy|
              widget_proxy.set_attribute(attribute_name, *args) if widget_proxy.has_attribute?(attribute_name, *args)
            end
          end
          super
        end
        
        private
        
        def build_checkboxes
          current_selection = selection
          @checkboxes = []
          items.each do |item|
            body_root.content {
              checkboxes << checkbox { |checkbox_proxy|
                text item
                on_widget_selected {
                  self.selection_indices = checkboxes.each_with_index.map {|cb, i| i if cb.selection}.to_a.compact
                }
              }
            }
          end
          observation_requests.to_a.each do |observation_request, block|
            delegate_observation_request_to_checkboxes(observation_request, &block)
          end
          self.selection = current_selection
        end
      end
      
      CheckGroup = CheckboxGroup # alias
    end
  end
end
