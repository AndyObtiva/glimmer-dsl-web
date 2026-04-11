# backtick_javascript: true

module ::Kernel
  # TODO contribute to Opal
  alias puts_without_glimmer puts
  def puts(*strs)
    puts_without_glimmer(*strs)
  rescue Exception
    strs.each do |str|
      `console.log(#{str})`
    end
  end
  
  # TODO contribute to Opal
  alias p_without_glimmer p
  def p(*args)
    p_without_glimmer(*args)
  rescue Exception
    args.each do |arg|
      `console.log(#{arg})`
    end
  end
end
