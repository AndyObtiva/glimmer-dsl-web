# TODO double check if the latest Opal implemented everything below already
class Exception
  def full_message
    backtrace.join("\n")
  end
end
