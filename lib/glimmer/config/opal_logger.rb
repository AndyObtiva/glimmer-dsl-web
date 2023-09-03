module Glimmer
  module Config
    class OpalLogger < Logger
      alias add_without_opal_logger add
      def add(severity, message = nil, progname = nil, &block)
        original_logdev = @pipe
        if severity == ERROR
          @pipe = $stderr
        else
          @pipe = original_logdev
        end
        add_without_opal_logger(severity, message, progname, &block)
      end
    end
  end
end
