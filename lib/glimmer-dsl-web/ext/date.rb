require 'date'
require 'time'

class DateTime < Date
  def initialize(*args, &block)
    @time = Time.new(*args, &block)
    methods_to_exclude = [:to_date, :to_time, :==, :eql?, :class] + Object.new.methods
    methods_to_define = @time.methods - methods_to_exclude
    methods_to_define.each do |method_name|
      singleton_class.define_method(method_name) do |*args, &block|
        @time.send(method_name, *args, &block)
      end
    end
  end

  def to_date
    @time.to_date
  end

  def to_time
    @time
  end

  def ==(other)
    return false if other.class != self.class
    year == other.year and
      month == other.month and
      day == other.day and
      hour == other.hour and
      min == other.min and
      sec == other.sec
  end
  alias eql? ==
end

class Date
  def to_datetime
    # TODO support timezone
    DateTime.new(year, month, day, hour, min, sec)
  end
end

class Time
  class << self
    alias new_original new
    def new(*args)
      if args.size >= 7
        Glimmer::Config.logger.debug "Dropped timezone #{args[6]} from Time.new(#{args.map(&:to_s)}) constructor arguments since Opal does not support it!"
        args = args[0...6]
      end
      new_original(*args)
    end
  end

  def to_datetime
    # TODO support timezone
    DateTime.new(year, month, day, hour, min, sec)
  end
end
