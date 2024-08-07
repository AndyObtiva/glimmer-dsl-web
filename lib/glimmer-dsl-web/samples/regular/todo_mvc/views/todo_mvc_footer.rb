class TodoMvcFooter
  include Glimmer::Web::Component
  
  markup {
    footer(class: 'info') {
      p {
        "Double-click to edit a todo"
      }
      p {
        "Created by #{a('Andy Maleh', href: 'https://github.com/AndyObtiva', target: '_blank')}"
      }
      p {
        "Part of #{a('TodoMVC', href: 'http://todomvc.com', target: '_blank')}"
      }
    }
  }
  
  style {
    r('footer.info') {
      margin '65px auto 0'
      color '#4d4d4d'
      font_size 11
      text_shadow '0 1px 0 rgba(255, 255, 255, 0.5)'
      text_align :center
    }
    
    r('footer.info p') {
      line_height '1'
    }
    
    r('footer.info a') {
      color :inherit
      text_decoration :none
      font_weight '400'
    }
    
    r('footer.info a:hover') {
      text_decoration :underline
    }
  }
end
