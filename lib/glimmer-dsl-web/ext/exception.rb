class Exception
  def full_message
    backtrace.join("\n")
  end
end
