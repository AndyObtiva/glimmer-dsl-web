require 'spec_helper'

module GlimmerSpec
  RSpec.describe 'table' do
    include Glimmer
    
    it 'renders and binds table widget with support for editing' do
      contact_manager_presenter = ContactManager::ContactManagerPresenter.new
      contact_manager_presenter.list
      Document.ready? do
        @target = shell {
          @table = table(:multi) { |table_proxy|
            table_column {
              text "First Name"
              width 80
              on_widget_selected {
                contact_manager_presenter.toggle_sort(:first_name)
              }
            }
            table_column {
              text "Last Name"
              width 120
              on_widget_selected {
                contact_manager_presenter.toggle_sort(:last_name)
              }
            }
            table_column {
              text "Email"
              width 200
              on_widget_selected {
                contact_manager_presenter.toggle_sort(:email)
              }
            }
            items bind(contact_manager_presenter, :results), column_properties(:first_name, :last_name, :email)
            on_mouse_up { |event|
              table_proxy.edit_table_item(event.table_item, event.column_index)
            }
          }
        }
        @target.open
        
        expect(@table).to be_a(Glimmer::SWT::TableProxy)
        
        table_column_element1 = Document.find('body > div#shell-1.shell > table#table-1.table > thead > tr > th#table-column-1.table-column').first
        expect(table_column_element1).to be_a(Element)
        expect(table_column_element1.html).to eq('First Name')
        expect(table_column_element1.attr('style')).to include('width: 80px;')
        
        table_column_element2 = Document.find('body > div#shell-1.shell > table#table-1.table > thead > tr > th#table-column-2.table-column').first
        expect(table_column_element2).to be_a(Element)
        expect(table_column_element2.html).to eq('Last Name')
        expect(table_column_element2.attr('style')).to include('width: 120px;')
        
        table_column_element3 = Document.find('body > div#shell-1.shell > table#table-1.table > thead > tr > th#table-column-3.table-column').first
        expect(table_column_element3).to be_a(Element)
        expect(table_column_element3.html).to eq('Email')
        expect(table_column_element3.attr('style')).to include('width: 200px;')
        
        table_item_element1 = Document.find('body > div#shell-1.shell > table#table-1.table > tbody > tr#table-item-1.table-item.selected').first
        expect(table_item_element1).to be_a(Element)
        expect(table_item_element1.html).to eq("<td data-column-index=\"0\">Liam</td><td data-column-index=\"1\">Smith</td><td data-column-index=\"2\">liam@smith.com</td>")
        
        table_item_element2 = Document.find('body > div#shell-1.shell > table#table-1.table > tbody > tr#table-item-2.table-item').first
        expect(table_item_element2).to be_a(Element)
        expect(table_item_element2.html).to eq("<td data-column-index=\"0\">Noah</td><td data-column-index=\"1\">Johnson</td><td data-column-index=\"2\">noah@johnson.com</td>")
         
        table_item_element3 = Document.find('body > div#shell-1.shell > table#table-1.table > tbody > tr#table-item-3.table-item').first
        expect(table_item_element3).to be_a(Element)
        expect(table_item_element3.html).to eq("<td data-column-index=\"0\">Madeline</td><td data-column-index=\"1\">Taylor</td><td data-column-index=\"2\">madeline@taylor.com</td>")
        
        table_item_cell_element1 = Document.find('body > div#shell-1.shell > table#table-1.table > tbody > tr#table-item-1.table-item.selected td:nth-child(1)').first
        expect(table_item_cell_element1.html).to eq('Liam')
        @table.edit_table_item(@table.items.first, 0)
        table_item_cell_element1 = Document.find('body > div#shell-1.shell > table#table-1.table > tbody > tr#table-item-1.table-item.selected td:nth-child(1)').first
        expect(table_item_cell_element1.html).to eq("<input type=\"text\" value=\"Liam\" style=\"max-width: 69px;\">")
      end
    end    
  end
end
