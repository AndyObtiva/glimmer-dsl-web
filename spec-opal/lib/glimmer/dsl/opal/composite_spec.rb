require 'spec_helper'
 
module GlimmerSpec
  RSpec.describe 'composite keyword' do
    include Glimmer
     
    it 'renders shell with composite containing combo (read only)' do
      Document.ready? do
        @target = shell {
          @composite = composite {
          }
        }
        @target.open
         
        expect(@composite).to be_a(Glimmer::SWT::CompositeProxy)
         
        composite_element = Document.find('body > div#shell-1.shell > div#composite-1.composite').first
        expect(composite_element).to be_a(Element)
      end
    end    
  end
end
