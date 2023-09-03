# require 'spec_helper'
# 
# module GlimmerSpec
#   RSpec.describe 'combo keyword' do
#     include Glimmer
#     
#     it 'renders shell with composite containing combo (read only)' do
#       Document.ready? do
#         @target = shell {
#           @composite = composite {
#             @combo = combo(:read_only) {
#             }
#           }
#         }
#         @target.open
#         
#         expect(@composite).to be_a(Glimmer::SWT::CompositeProxy)
#         expect(@combo).to be_a(Glimmer::SWT::ComboProxy)
#         
#         composite_element = Document.find('body > div#shell-1.shell > div#composite-1.composite').first
#         expect(composite_element).to be_a(Element)
#         combo_element = Document.find('body > div#shell-1.shell > div#composite-1.composite > select#combo-1.combo').first
#         expect(combo_element).to be_a(Element)
#       end
#     end
#     
#     it 'renders shell with composite containing data-bound combo (read only)' do
#       person = Person.new
#       Document.ready? do
#         @target = shell {
#           composite {
#             combo(:read_only) {
#               selection bind(person, :country)
#             }
#           }
#         }
#        
#         composite_element = Document.find('body > div#shell-1.shell > div#composite-1.composite').first
#         expect(composite_element).to be_a(Element)
#          
#         combo_element = Document.find('body > div#shell-1.shell > div#composite-1.composite > select#combo-1.combo').first
#         expect(combo_element).to be_a(Element)
#         expect(combo_element.value).to eq('Canada')
#          
#         combo_option_element1 = Document.find('body > div#shell-1.shell > div#composite-1.composite > select#combo-1.combo > option:nth-child(1)').first
#         expect(combo_option_element1).to be_a(Element)
#         expect(combo_option_element1.html).to eq('')
#           
#         combo_option_element2 = Document.find('body > div#shell-1.shell > div#composite-1.composite > select#combo-1.combo > option:nth-child(2)').first
#         expect(combo_option_element2).to be_a(Element)
#         expect(combo_option_element2.html).to eq('Canada')
#           
#         combo_option_element3 = Document.find('body > div#shell-1.shell > div#composite-1.composite > select#combo-1.combo > option:nth-child(3)').first
#         expect(combo_option_element3).to be_a(Element)
#         expect(combo_option_element3.html).to eq('US')
#           
#         combo_option_element4 = Document.find('body > div#shell-1.shell > div#composite-1.composite > select#combo-1.combo > option:nth-child(4)').first
#         expect(combo_option_element4).to be_a(Element)
#         expect(combo_option_element4.html).to eq('Mexico')      
#           
#         combo_element.value = 'US'
#         combo_element.trigger(:change)
#           
#         expect(person.country).to eq('US')
#         
#         person.country = 'Mexico'        
#         
#         expect(combo_element.value).to eq('Mexico')
#       end      
#     end
#   end
# end
