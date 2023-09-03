require 'spec_helper'
 
module GlimmerSpec
  RSpec.describe 'shell keyword' do
    include Glimmer
     
    let(:title) {'Hello, World!'}
     
    it 'renders empty shell with title and CSS shell-style div' do
      Document.ready? do
        @target = shell {
          text title
        }
        @target.open
         
        expect(@target).to be_a(Glimmer::SWT::ShellProxy)
   
        expect(Document.title).to eq(title)
        expect(Document.find('body > div#shell-1.shell').first).to be_a(Element)
        expect(Document.find('body > div#shell-1.shell > style.common-style').first.html).to eq(@target.style_dom_css)
        expect(Document.find('body > div#shell-1.shell > style.shell-style').first.html).to eq(@target.style_dom_shell_css)
        expect(Document.find('body > div#shell-1.shell > style.list-style').first.html).to eq(@target.style_dom_list_css)
        expect(Document.find('body > div#shell-1.shell > style.tab-style').first.html).to eq(@target.style_dom_tab_css)
#         expect(Document.find('body > div#shell-1.shell > style.tab-item-style').first.html).to eq(@target.style_dom_tab_item_css)
#         expect(Document.find('body > div#shell-1.shell > style.modal-style').first.html).to eq(@target.style_dom_modal_css)
        expect(Document.find('body > div#shell-1.shell > style.table-style').first.html).to eq(@target.style_dom_table_css)
      end           
    end
     
    it 'sets minimum_size' do
      Document.ready? do
        @target = shell {
          minimum_size 640, 480
        }
        @target.open
         
        expect(@target).to be_a(Glimmer::SWT::ShellProxy)
   
        shell_element = Document.find('body > div#shell-1.shell').first
        expect(shell_element).to be_a(Element)
        expect(shell_element.css('min-width')).to eq("640px")
        expect(shell_element.css('min-height')).to eq("480px")
        
        body_element = Document.find('body')
        expect(body_element.css('min-width')).to eq("640px")
        expect(body_element.css('min-height')).to eq("480px")
      end
    end
  end
end
