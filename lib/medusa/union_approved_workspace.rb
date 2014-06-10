require 'drb'

require_relative 'parent_termination_watcher'
require_relative 'ruby_fixes'

module Medusa

  # The new Union Approved Workspace program was recently introduced by the
  # minion's Union to provide them a safe execution environment for their
  # work.
  #
  # Technically speaking, this workspace forks the process, and establishes
  # DRb communication between the parent and child processes. One for the
  # minion's commands, and one for reporting back to the Union their results.
  class UnionApprovedWorkspace
    def initialize(port)
      @port = port
      @logger = Medusa.logger.tagged(self.class.name)
    end

    # Embrace a minion into the workspace. Forks the process, and runs the
    # minion in there. Method calls from the parent process to the minion
    # are run inside the forked process.
    def embrace(target, reporting_uri)
      @target = target

      @pid = fork do
        $0 = "[medusa] #{target.class.name} #{target.name}"

        terminator = ParentTerminationWatcher.new

        reporting_client = DRbObject.new(nil, reporting_uri)
        target.report_to(reporting_client)

        server = DRb::DRbServer.new("druby://localhost:#{@port}", target)

        terminator.block_until_parent_dead!
      end
    end

    # Verifies the connection to the child process running the 
    # minion server is alive.
    def verify
      tries = 0

      begin
        @logger.debug("Checking connection to #{@port}...")
        object = DRbObject.new(nil, "druby://localhost:#{@port}")
        object.to_s
        true
      rescue Errno::ECONNREFUSED, DRb::DRbConnError
        @logger.debug("Retrying connection to #{@port}...")
        raise "Couldn't establish workspace connection to #{@port}" if tries > 10

        tries += 1
        sleep(0.1)
        retry
      end
    end

    def release
      Process.kill("KILL", @pid) if @pid
      @pid = nil
      @target = nil
      @reporter = nil
    end

    # Forwards method calls onto the minion's server running inside the forked
    # process from #embrace.
    def method_missing(name, *args)
      client = DRbObject.new(nil, "druby://localhost:#{@port}")
      last_error = nil

      work_thread = Thread.new do
        begin
          client.send(name, *args)
        rescue => ex
          last_error = ex
        end
      end

      work_thread.join
      raise last_error if last_error
    end
  end
end