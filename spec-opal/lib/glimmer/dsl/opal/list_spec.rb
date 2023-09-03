require 'spec_helper'

module GlimmerSpec
  RSpec.describe 'list keyword' do
    include Glimmer
    
    it 'renders and binds list widget for single selection' do
      person = Person.new
      Document.ready? do
        @target = shell {
          @list = list {
            selection bind(person, :country)
          }
        }
        @target.open
        
        expect(@list).to be_a(Glimmer::SWT::ListProxy)
         
        list_element = Document.find('body > div#shell-1.shell > ul#list-1.list').first
        expect(list_element).to be_a(Element)
        
        selected_list_item_element = Document.find('body > div#shell-1.shell > ul#list-1.list > li.selected').first
        expect(selected_list_item_element).to be_a(Element)
        expect(selected_list_item_element.html).to eq(person.country)
         
        person.country = 'US'
        selected_list_item_element = Document.find('body > div#shell-1.shell > ul#list-1.list > li.selected').first
        expect(selected_list_item_element.html).to eq('US')
         
        new_selected_list_item_element = Document.find('body > div#shell-1.shell > ul#list-1.list > li:nth-child(4)').first
        expect(new_selected_list_item_element.html).to eq('Mexico')
        new_selected_list_item_element.trigger(:click)
         
        expect(person.country).to eq('Mexico')
      end
    end
        
    it 'renders and binds list widget for multi selection' do
      person = Person.new
      Document.ready? do
        @target = shell {
          @list = list(:multi) {
            selection bind(person, :provinces)
          }
        }
        @target.open
        
        expect(@list).to be_a(Glimmer::SWT::ListProxy)
         
        list_element = Document.find('body > div#shell-1.shell > ul#list-1.list').first
        expect(list_element).to be_a(Element)
        
        selected_list_item_elements = Document.find('body > div#shell-1.shell > ul#list-1.list > li.selected')
        expect(selected_list_item_elements.to_a.map(&:html)).to eq(["Quebec", "Manitoba", "Alberta"])

        person.provinces << 'Ontario'
        selected_list_item_elements = Document.find('body > div#shell-1.shell > ul#list-1.list > li.selected')
        expect(selected_list_item_elements.to_a.map(&:html).sort).to eq(["Quebec", "Manitoba", "Alberta", "Ontario"].sort)
          
        new_selected_list_item_element = Document.find('body > div#shell-1.shell > ul#list-1.list > li:nth-child(5)').first
        expect(new_selected_list_item_element.html).to eq('Saskatchewan')

        new_selected_list_item_element.trigger(:click)
           
        expect(person.provinces).to eq(["Saskatchewan"])
        
        # TODO add more expectations for meta (and shift) key presses once you figure out how
      end
    end
  end
end
