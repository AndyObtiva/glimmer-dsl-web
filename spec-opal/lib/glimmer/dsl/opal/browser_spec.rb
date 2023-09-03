require 'spec_helper'

module GlimmerSpec
  RSpec.describe 'browser keyword' do
    include Glimmer
    
    it 'renders browser widget' do
      Document.ready? do
        @target = shell {
          @browser = browser {
            url 'http://brightonresort.com/about'
          }
        }
        @target.open
        
        expect(@browser).to be_a(Glimmer::SWT::BrowserProxy)
         
        browser_element = Document.find('body > div#shell-1.shell > iframe[src="http://brightonresort.com/about"][frameBorder="0"]#browser-1.browser').first
        expect(browser_element).to be_a(Element)
      end
    end    
   
  end
end
