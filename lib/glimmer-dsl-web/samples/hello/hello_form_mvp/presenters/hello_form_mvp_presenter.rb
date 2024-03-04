require_relative '../models/contact'

class HelloFormMvpPresenter
  attr_accessor :contacts
  
  def initialize
    @contacts = fetch_contacts
  end
  
  def fetch_contacts
    [
      Contact.new(name: 'John Doe', email: 'johndoe@example.com'),
      Contact.new(name: 'Jane Doe', email: 'janedoe@example.com'),
    ]
  end
  
  def new_contact
    @new_contact ||= Contact.new
  end
  
  def add_contact
    contacts << Contact.new(name: new_contact.name, email: new_contact.email)
    new_contact.name = new_contact.email = ''
  end
end
