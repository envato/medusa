module Medusa #:nodoc:
  # Trace output when in verbose mode.
  module Trace
    module ClassMethods
      # Make a class traceable. Takes one parameter,
      # which is the prefix for the trace to identify this class
      def traceable(prefix = self.class.to_s)
        include Medusa::Trace::InstanceMethods
        class << self; attr_accessor :_traceable_prefix; end
        self._traceable_prefix = prefix
        $stdout.sync = true
      end
    end

    module InstanceMethods
      # Trace some output with the class's prefix and a newline.
      # Checks to ensure we're running verbosely.
      def trace(str)
        $stdout.write "#{Time.now.to_f} #{self.class._traceable_prefix}| #{str}\n" if @verbose
      end

      def redirect_output file_name
        begin
          $stderr = $stdout =  File.open(file_name, 'a')
        rescue
          # it should always redirect output in order to handle unexpected interruption
          # successfully
          $stderr = $stdout =  File.open("some-log.log", 'a')
        end
      end

    end
  end
end
Object.extend(Medusa::Trace::ClassMethods)
