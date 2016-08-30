module Agents
  class PublisherTasks < Agent
    # docs for how to create own Agent - https://github.com/cantino/huginn/wiki/Creating-a-new-agent
    can_dry_run! #it gives run agent manually via /agents/:agent_id/dry_runs
    default_schedule "never"

    description <<-MD
      The PublisherAgent creates an event for sending emails with La Gazette Turf to users.
    MD

    def default_options
      { 
        pipeline_name: 'Gazette',
        packages: ['js2', 'q2']
      }
    end

    # check that pipeline_name and packages are given by user
    def validate_options
      errors.add(:base, 'pipeline_name is required') unless options['pipeline_name'].present?
      errors.add(:base, 'packages is required') unless options['packages'].present?
    end

    # @return [Array] list of packages from options
    def packages
      return self.options[:packages] if instance_of?(Array)
      self.options[:packages].split(",").map(&:strip)
    end

    def working?
      !recent_error_logs?
    end

    # Launch Orchestrator::Tasks::Pipelines::#{options.pipeline}.
    # It does nothing if either incoming_events are blank or there are not any information about another package or we have information about other packages but for another date.
    # It runs pipeline only if today we get all packages from options[:packages] (js2, q2 for example) from publisher api for the same date.
    def receive(incoming_events)
      event = incoming_events.first
      return if event.blank? 
      return if (not dry_run?) && Event.where(agent_id: event.agent_id).select do |e| 
        begin
          e.payload[:date].to_date == event.payload[:date].to_date && packages.include?(event.payload[:package_type])
        rescue Exception => e
          false
        end
      end.map(&:payload).uniq.count < packages.count

      date = event.payload[:date] || Date.tomorrow.to_s
      klass    = "Orchestrator::Tasks::Pipelines::#{self.options[:pipeline_name]}".constantize
      pipeline = klass.new(date)

      pipeline.launch!
      create_event payload: pipeline.response
    end

    def check
      create_event :payload => interpolated
    end

  end
end
