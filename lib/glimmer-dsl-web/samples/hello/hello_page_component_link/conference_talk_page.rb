require 'glimmer-dsl-web'

require 'glimmer-dsl-web/samples/hello/hello_page_component_link/models/conference_talk'
require 'glimmer-dsl-web/samples/hello/hello_page_component_link/conference_talks_page'

class ConferenceTalkPage
  include Glimmer::Web::Component
  
  attribute :conference_talk_attributes
  attr_reader :conference_talk
  
  before_render do
    @conference_talk = ConferenceTalk.new(conference_talk_attributes)
  end
  
  # structure is an alias for markup
  structure {
    div {
      h1 {
        span { 'Talk Title: ' }
        span { conference_talk.title }
      }
      h2 {
        span { 'Speaker: ' }
        span { conference_talk.speaker }
      }
      h3 {
        span { 'Time: ' }
        span { conference_talk.time }
      }
      p { strong('Description:') }
      p { conference_talk.description }
      p { strong('Bio:') }
      p { conference_talk.bio }
      div {
        # If component_class/component_attributes are unspecified, this looks for the component in browser history,
        # assuming this page was reached from the page_url
        # If the user lands directly on this page, then when navigating the link, it simply visits the page_url
        page_component_link(text: "Back to conference talks", page_url: '/conference_talks')
      }
    }
  }
end
