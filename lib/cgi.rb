class CGI
  class << self
    def escapeHTML(string)
      string.
        gsub('&', '&amp;').
        gsub('<', '&lt;').
        gsub('>', '&gt;').
        gsub("'", '&apos;').
        gsub('"', '&quot;')
    end
    alias escape_html escapeHTML
    
  end
end
