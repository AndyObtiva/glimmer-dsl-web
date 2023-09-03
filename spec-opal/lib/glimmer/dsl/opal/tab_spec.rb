require 'spec_helper'

module GlimmerSpec
  RSpec.describe 'tab' do
    include Glimmer
    
    it 'renders tabs with first one selected by default' do
      Document.ready? do
        @target = shell {
          @tab_folder = tab_folder {
            @tab_item1 = tab_item {
              text "English"
              @label1 = label {
                text "Hello, World!"
              }
            }
            @tab_item2 = tab_item {
              text "French"
              @label2 = label {
                text "Bonjour, Univers!"
              }
            }
          }
        }
        @target.open
        
        expect(@tab_folder).to be_a(Glimmer::SWT::TabFolderProxy)
        expect(@tab_item1).to be_a(Glimmer::SWT::TabItemProxy)
        expect(@tab_item2).to be_a(Glimmer::SWT::TabItemProxy)
        
        expect(@tab_folder.children.to_a[0]).to eq(@tab_item1)
        expect(@tab_folder.children.to_a[1]).to eq(@tab_item2)
        
        expect(@tab_item1.text).to eq('English')
        expect(@tab_item2.text).to eq('French')
        
        expect(@tab_item1.children.to_a.first).to eq(@label1)
        expect(@tab_item2.children.to_a.first).to eq(@label2)
        
        tab_folder_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder').first
        expect(tab_folder_element).to be_a(Element)
        
        tab_folder_tabs_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-folder-1-tabs').first
        expect(tab_folder_tabs_element).to be_a(Element)
        
        selected_tab_item1_tab_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-folder-1-tabs > button#tab-item-1-tab.tab.selected').first
        expect(selected_tab_item1_tab_element).to be_a(Element)
        
        tab_item2_tab_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-folder-1-tabs > button#tab-item-2-tab.tab').first
        expect(tab_item2_tab_element).to be_a(Element)
        
        tab_item1_content_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-item-1').first
        expect(tab_item1_content_element).to be_a(Element)
        
        hidden_tab_item2_content_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-item-2.hide').first
        expect(hidden_tab_item2_content_element).to be_a(Element)
        
        tab_item1_label_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-item-1 > label#label-1.label').first
        expect(tab_item1_label_element).to be_a(Element)
        
        tab_item2_label_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-item-2 > label#label-2.label').first
        expect(tab_item2_label_element).to be_a(Element)
      end
    end    
  
    it 'selects second tab' do
      Document.ready? do
        @target = shell {
          @tab_folder = tab_folder {
            @tab_item1 = tab_item {
              text "English"
              @label1 = label {
                text "Hello, World!"
              }
            }
            @tab_item2 = tab_item {
              text "French"
              @label2 = label {
                text "Bonjour, Univers!"
              }
            }
          }
        }
        @target.open
        
        tab_item2_tab_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-folder-1-tabs > button#tab-item-2-tab.tab').first
        tab_item2_tab_element.trigger(:click)
        
        tab_item1_tab_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-folder-1-tabs > button#tab-item-1-tab.tab:not(.selected)').first
        expect(tab_item1_tab_element).to be_a(Element)
        
        selected_tab_item2_tab_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-folder-1-tabs > button#tab-item-2-tab.tab.selected').first
        expect(selected_tab_item2_tab_element).to be_a(Element)        
        
        hidden_tab_item1_content_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-item-1.hide').first
        expect(hidden_tab_item1_content_element).to be_a(Element)
        
        tab_item2_content_element = Document.find('body > div#shell-1.shell > div#tab-folder-1.tab-folder > div#tab-item-2:not(.hide)').first
        expect(tab_item2_content_element).to be_a(Element)
      end
    end  
  end
end
