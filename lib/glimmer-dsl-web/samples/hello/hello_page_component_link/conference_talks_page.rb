require 'glimmer-dsl-web'

require 'glimmer-dsl-web/samples/hello/hello_page_component_link/models/conference_talk'
require 'glimmer-dsl-web/samples/hello/hello_page_component_link/conference_talk_page'

class ConferenceTalksPage
  include Glimmer::Web::Component
  
  attribute :conference_talks_attributes
  
  # structure is an alias for markup
  structure {
    div {
      h1 { 'Conference Talks' }
      ul {
        conference_talks_attributes.each do |conference_talk_attributes|
          conference_talk = ConferenceTalk.new(conference_talk_attributes)
          li {
            page_component_link(
              text: conference_talk.to_s,
              component_class: ConferenceTalkPage,
              component_attributes: {conference_talk_attributes:},
              page_url: conference_talk.resource_path,
            )
          }
        end
      }
    }
  }
end
