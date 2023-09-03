require 'spec_helper'
 
module GlimmerSpec
  RSpec.describe 'button keyword' do
    include Glimmer
     
    it 'renders shell with composite containing listener-bound button' do
      person = Person.new
      Document.ready? do
        @target = shell {
          composite {
            button {
              text "Reset"
              on_widget_selected do
                person.reset_country
              end
            }
          }
        }
          
        button_element = Document.find('body > div#shell-1.shell > div#composite-1.composite > button#button-1.button').first
        expect(button_element).to be_a(Element)
         
        person.country = 'Mexico'
        button_element.trigger(:click)
         
        expect(person.country).to eq('Canada')
      end      
    end
  end
end
