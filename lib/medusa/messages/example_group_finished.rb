module Medusa #:nodoc:
  module Messages #:nodoc:

    class ExampleGroupFinished < Medusa::Message
      message_attr :group_name

      include WorkerPassthrough

      def handle_by_master(master, worker)
        master.notify! :example_group_finished, group_name
      end

    end

  end
end