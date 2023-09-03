require 'spec_helper'
 
module GlimmerSpec
  RSpec.describe 'label keyword' do
    include Glimmer
     
    let(:title) {'Hello, World!'}
         
    it 'renders shell with label content' do
      Document.ready? do
        @target = shell {
          @label = label {
            text title
          }
        }
        @target.open
         
        expect(@label).to be_a(Glimmer::SWT::LabelProxy)
 
        label_element = Document.find('body > div#shell-1.shell > label#label-1.label').first
        expect(label_element).to be_a(Element)
        expect(label_element.html).to eq(title)
      end
    end    
  end
end
