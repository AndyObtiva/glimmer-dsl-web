require_relative "contact"

class ContactManager
  class ContactRepository
    NAMES_FIRST = %w[
      Liam
      Noah
      Madeline
    ]
    NAMES_LAST = %w[
      Smith
      Johnson
      Taylor
    ]
    def initialize(contacts = nil)
      @contacts = contacts || 3.times.map do |n|
        first_name = NAMES_FIRST[n]
        last_name = NAMES_LAST[n]
        email = "#{first_name}@#{last_name}.com".downcase
        Contact.new(
          first_name: first_name,
          last_name: last_name,
          email: email
        )
      end
    end
  
    def find(attribute_filter_map)
      @contacts.find_all do |contact|
        match = true
        attribute_filter_map.keys.each do |attribute_name|
          contact_value = contact.send(attribute_name).downcase
          filter_value = attribute_filter_map[attribute_name].downcase
          match = false unless contact_value.match(filter_value)
        end
        match
      end
    end
  end
end
