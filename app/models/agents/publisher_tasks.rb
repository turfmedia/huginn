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
        date: '',
        package_type: '',
      }
    end

    # 
    def validate_options
      errors.add(:base, 'date is required') unless options['date'].present?
    end

    def working?
      !recent_error_logs?
    end

    # Launch Orchestrator::Tasks::Pipelines::Gazette pipeline.
    # It does nothing if either incoming_events are blank or there are not any information about another package or we have information about other packages but for another date.
    # It runs pipeline only if today we get two packages (js2, q2) from publisher api for the same date.
    def receive(incoming_events)
      event = incoming_events.first
      return if event.blank? 
      return if (not dry_run?) && Event.where(agent_id: event.agent_id).select do |e| 
        begin
          e.payload[:date].to_date == event.payload[:date].to_date 
        rescue Exception => e
          false
        end
      end.map(&:payload).uniq.count < 2

      date = event.payload[:date] || Date.tomorrow.to_s
      gazette = Orchestrator::Tasks::Pipelines::Gazette.new(date)

      if gazette.launch!
        create_event payload: { date: date, status: "ok", pdf_link: gazette.link_to_pdf }
      else
        event = create_event payload: { date: date, status: "failure" }
      end
    end

    def check
      create_event :payload => interpolated
    end

  end
end
