class Person
  attr_accessor :country, :country_options
  attr_accessor :provinces, :provinces_options
  attr_accessor :date_of_birth
  
  def initialize
    self.country_options=["", "Canada", "US", "Mexico"]
    self.country = "Canada"
    self.provinces_options=[
      "",
      "Quebec",
      "Ontario",
      "Manitoba",
      "Saskatchewan",
      "Alberta",
      "British Columbia",
      "Nova Skotia",
      "Newfoundland"
    ]
    self.provinces = ["Quebec", "Manitoba", "Alberta"]
  end

  def reset_country
    self.country = "Canada"
  end

  def reset_provinces
    self.provinces = ["Quebec", "Manitoba", "Alberta"]
  end
end
