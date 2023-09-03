require 'spec_helper'
 
module GlimmerSpec
  RSpec.describe 'message_box keyword' do
    include Glimmer
     
    let(:title) {'Hello, World!'}
    let(:message) {'Welcome to Glimmer DSL for Opal!'}
     
    it 'renders empty shell with title and CSS shell-style div' do
      Document.ready? do
        @target = shell {
        }
        @target.open
        
        @message_box = message_box(@target) {
          text title
          message message
        }
         
        expect(@message_box).to be_a(Glimmer::SWT::MessageBoxProxy)
      end
    end
  end
end
