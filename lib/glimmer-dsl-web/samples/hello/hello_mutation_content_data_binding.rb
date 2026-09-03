require 'glimmer-dsl-web'

unless Object.const_defined?(:ListPresenter) # this is only needed in sample selector app due to file reloading, but not in real apps.
  class ListPresenter
    attr_accessor :list, :new_list_item, :insert_index
    
    def initialize
      @list = []
      @new_list_item = ''
      @insert_index = 0
    end
    
    def append_list_item
      list.push(new_list_item)
      clear_new_list_item
    end
    
    def prepend_list_item
      list.prepend(new_list_item)
      clear_new_list_item
    end
    
    def insert_list_item
      list.insert(insert_index, new_list_item)
      clear_new_list_item
    end
    
    def clear_new_list_item
      self.new_list_item = ''
    end
    
    def entering_new_list_item?
      new_list_item.empty?
    end
    alias edit_list_disabled? entering_new_list_item?
    
    def max_insert_index
      list.size
    end
  end
end

unless Object.const_defined?(:HelloMutationContentDataBinding) # this is only needed in sample selector app due to file reloading, but not in real apps.
  class HelloMutationContentDataBinding
    include Glimmer::Web::Component
    
    before_render do
      @list_presenter = ListPresenter.new
    end
    
    markup {
      div {
        h1('Hello, Mutation Content Data-Binding!')
        
        p {
          'Add items to a list via content data-binding (which performs implicit DOM mutations).'
        }
        
        div(class: 'actions') {
          input(placeholder: 'Enter list item content') {
            value <=> [@list_presenter, :new_list_item]
            focused <= [@list_presenter, :entering_new_list_item?, computed_by: :new_list_item]
          }
          
          button('Append list item') {
            disabled <= [@list_presenter, :edit_list_disabled?, computed_by: :new_list_item]
            
            onclick do
              @list_presenter.append_list_item
            end
          }
          
          button('Prepend list item') {
            disabled <= [@list_presenter, :edit_list_disabled?, computed_by: :new_list_item]
            
            onclick do
              @list_presenter.prepend_list_item
            end
          }
          
          button('Insert list item') {
            disabled <= [@list_presenter, :edit_list_disabled?, computed_by: :new_list_item]
            
            onclick do
              @list_presenter.insert_list_item
            end
          }
          
          label(for: 'insert-index-input') { 'at index: ' }
          input(id: 'insert-index-input', type: 'number') {
            value <=> [@list_presenter, :insert_index]
            min 0
            max <= [@list_presenter, :max_insert_index, computed_by: :list]
          }
        }
        
        ul {
          content(@list_presenter, :list) {
            @list_presenter.list.each do |list_item|
              li { list_item }
            end
          }
        }
      }
    }
    
    style {
      r('.actions input, .actions button') {
        margin '10px 10px 10px 0'
      }
      
      r('.actions input#insert-index-input') {
        width 40
      }
      
      r('.actions label[for=insert-index-input]') {
        margin_left -5
      }
    }
  end
end

Document.ready? do
  HelloMutationContentDataBinding.render
end
