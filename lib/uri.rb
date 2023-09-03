# Missing URI module class features

module URI
  class HTTP
    REGEX = /([^:]+):\/\/([^\/])\/([^?]*)\??(.*)/
    
    def initialize(url)
      @url = url
      uri_match = url.match(REGEX).to_a
      @scheme = uri_match[1]
      @host = uri_match[2]
      @path = uri_match[3]
      @query = uri_match[4]
      # TODO fragment
    end
    
    def to_s
      url
    end
  end
  
  TBLENCWWWCOMP_ = {"\u0000"=>"%00", "\u0001"=>"%01", "\u0002"=>"%02", "\u0003"=>"%03", "\u0004"=>"%04", "\u0005"=>"%05", "\u0006"=>"%06", "\a"=>"%07", "\b"=>"%08", "\t"=>"%09", "\n"=>"%0A", "\v"=>"%0B", "\f"=>"%0C", "\r"=>"%0D", "\u000E"=>"%0E", "\u000F"=>"%0F", "\u0010"=>"%10", "\u0011"=>"%11", "\u0012"=>"%12", "\u0013"=>"%13", "\u0014"=>"%14", "\u0015"=>"%15", "\u0016"=>"%16", "\u0017"=>"%17", "\u0018"=>"%18", "\u0019"=>"%19", "\u001A"=>"%1A", "\e"=>"%1B", "\u001C"=>"%1C", "\u001D"=>"%1D", "\u001E"=>"%1E", "\u001F"=>"%1F", " "=>"+", "!"=>"%21", "\""=>"%22", "#"=>"%23", "$"=>"%24", "%"=>"%25", "&"=>"%26", "'"=>"%27", "("=>"%28", ")"=>"%29", "*"=>"%2A", "+"=>"%2B", ","=>"%2C", "-"=>"%2D", "."=>"%2E", "/"=>"%2F", "0"=>"%30", "1"=>"%31", "2"=>"%32", "3"=>"%33", "4"=>"%34", "5"=>"%35", "6"=>"%36", "7"=>"%37", "8"=>"%38", "9"=>"%39", ":"=>"%3A", ";"=>"%3B", "<"=>"%3C", "="=>"%3D", ">"=>"%3E", "?"=>"%3F", "@"=>"%40", "A"=>"%41", "B"=>"%42", "C"=>"%43", "D"=>"%44", "E"=>"%45", "F"=>"%46", "G"=>"%47", "H"=>"%48", "I"=>"%49", "J"=>"%4A", "K"=>"%4B", "L"=>"%4C", "M"=>"%4D", "N"=>"%4E", "O"=>"%4F", "P"=>"%50", "Q"=>"%51", "R"=>"%52", "S"=>"%53", "T"=>"%54", "U"=>"%55", "V"=>"%56", "W"=>"%57", "X"=>"%58", "Y"=>"%59", "Z"=>"%5A", "["=>"%5B", "\\"=>"%5C", "]"=>"%5D", "^"=>"%5E", "_"=>"%5F", "`"=>"%60", "a"=>"%61", "b"=>"%62", "c"=>"%63", "d"=>"%64", "e"=>"%65", "f"=>"%66", "g"=>"%67", "h"=>"%68", "i"=>"%69", "j"=>"%6A", "k"=>"%6B", "l"=>"%6C", "m"=>"%6D", "n"=>"%6E", "o"=>"%6F", "p"=>"%70", "q"=>"%71", "r"=>"%72", "s"=>"%73", "t"=>"%74", "u"=>"%75", "v"=>"%76", "w"=>"%77", "x"=>"%78", "y"=>"%79", "z"=>"%7A", "{"=>"%7B", "|"=>"%7C", "}"=>"%7D", "~"=>"%7E", "\u007F"=>"%7F", "\u0080"=>"%80", "\u0081"=>"%81", "\u0082"=>"%82", "\u0083"=>"%83", "\u0084"=>"%84", "\u0085"=>"%85", "\u0086"=>"%86", "\u0087"=>"%87", "\u0088"=>"%88", "\u0089"=>"%89", "\u008A"=>"%8A", "\u008B"=>"%8B", "\u008C"=>"%8C", "\u008D"=>"%8D", "\u008E"=>"%8E", "\u008F"=>"%8F", "\u0090"=>"%90", "\u0091"=>"%91", "\u0092"=>"%92", "\u0093"=>"%93", "\u0094"=>"%94", "\u0095"=>"%95", "\u0096"=>"%96", "\u0097"=>"%97", "\u0098"=>"%98", "\u0099"=>"%99", "\u009A"=>"%9A", "\u009B"=>"%9B", "\u009C"=>"%9C", "\u009D"=>"%9D", "\u009E"=>"%9E", "\u009F"=>"%9F", "\u00A0"=>"%A0", "\u00A1"=>"%A1", "\u00A2"=>"%A2", "\u00A3"=>"%A3", "\u00A4"=>"%A4", "\u00A5"=>"%A5", "\u00A6"=>"%A6", "\u00A7"=>"%A7", "\u00A8"=>"%A8", "\u00A9"=>"%A9", "\u00AA"=>"%AA", "\u00AB"=>"%AB", "\u00AC"=>"%AC", "\u00AD"=>"%AD", "\u00AE"=>"%AE", "\u00AF"=>"%AF", "\u00B0"=>"%B0", "\u00B1"=>"%B1", "\u00B2"=>"%B2", "\u00B3"=>"%B3", "\u00B4"=>"%B4", "\u00B5"=>"%B5", "\u00B6"=>"%B6", "\u00B7"=>"%B7", "\u00B8"=>"%B8", "\u00B9"=>"%B9", "\u00BA"=>"%BA", "\u00BB"=>"%BB", "\u00BC"=>"%BC", "\u00BD"=>"%BD", "\u00BE"=>"%BE", "\u00BF"=>"%BF", "\u00C0"=>"%C0", "\u00C1"=>"%C1", "\u00C2"=>"%C2", "\u00C3"=>"%C3", "\u00C4"=>"%C4", "\u00C5"=>"%C5", "\u00C6"=>"%C6", "\u00C7"=>"%C7", "\u00C8"=>"%C8", "\u00C9"=>"%C9", "\u00CA"=>"%CA", "\u00CB"=>"%CB", "\u00CC"=>"%CC", "\u00CD"=>"%CD", "\u00CE"=>"%CE", "\u00CF"=>"%CF", "\u00D0"=>"%D0", "\u00D1"=>"%D1", "\u00D2"=>"%D2", "\u00D3"=>"%D3", "\u00D4"=>"%D4", "\u00D5"=>"%D5", "\u00D6"=>"%D6", "\u00D7"=>"%D7", "\u00D8"=>"%D8", "\u00D9"=>"%D9", "\u00DA"=>"%DA", "\u00DB"=>"%DB", "\u00DC"=>"%DC", "\u00DD"=>"%DD", "\u00DE"=>"%DE", "\u00DF"=>"%DF", "\u00E0"=>"%E0", "\u00E1"=>"%E1", "\u00E2"=>"%E2", "\u00E3"=>"%E3", "\u00E4"=>"%E4", "\u00E5"=>"%E5", "\u00E6"=>"%E6", "\u00E7"=>"%E7", "\u00E8"=>"%E8", "\u00E9"=>"%E9", "\u00EA"=>"%EA", "\u00EB"=>"%EB", "\u00EC"=>"%EC", "\u00ED"=>"%ED", "\u00EE"=>"%EE", "\u00EF"=>"%EF", "\u00F0"=>"%F0", "\u00F1"=>"%F1", "\u00F2"=>"%F2", "\u00F3"=>"%F3", "\u00F4"=>"%F4", "\u00F5"=>"%F5", "\u00F6"=>"%F6", "\u00F7"=>"%F7", "\u00F8"=>"%F8", "\u00F9"=>"%F9", "\u00FA"=>"%FA", "\u00FB"=>"%FB", "\u00FC"=>"%FC", "\u00FD"=>"%FD", "\u00FE"=>"%FE", "\u00FF"=>"%FF"}
  TBLDECWWWCOMP_ = TBLENCWWWCOMP_.invert
  
  # Encodes given +str+ to URL-encoded form data.
  #
  # This method doesn't convert *, -, ., 0-9, A-Z, _, a-z, but does convert SP
  # (ASCII space) to + and converts others to %XX.
  #
  # If +enc+ is given, convert +str+ to the encoding before percent encoding.
  #
  # This is an implementation of
  # https://www.w3.org/TR/2013/CR-html5-20130806/forms.html#url-encoded-form-data.
  #
  # See URI.decode_www_form_component, URI.encode_www_form.
  def self.encode_www_form_component(str, enc=nil)
    str = str.to_s.dup
    if str.encoding != Encoding::ASCII_8BIT
      if enc && enc != Encoding::ASCII_8BIT
        str.encode!(Encoding::UTF_8, invalid: :replace, undef: :replace)
        str.encode!(enc, fallback: ->(x){"&##{x.ord};"})
      end
      str.force_encoding(Encoding::ASCII_8BIT)
    end
    str = str.gsub(/[^*\-.0-9A-Z_a-z]/, TBLENCWWWCOMP_)
    str.force_encoding(Encoding::US_ASCII)
  end

  # Decodes given +str+ of URL-encoded form data.
  #
  # This decodes + to SP.
  #
  # See URI.encode_www_form_component, URI.decode_www_form.
  def self.decode_www_form_component(str, enc=Encoding::UTF_8)
    raise ArgumentError, "invalid %-encoding (#{str})" if /%(?![0-9a-fA-F][0-9a-fA-F])/ =~ str
    str.b.gsub(/\+|%[0-9a-fA-F][0-9a-fA-F]/, TBLDECWWWCOMP_).force_encoding(enc)
  end
end

module Kernel
  def URI(url)
    URI::HTTP.new(url)
  end
end
