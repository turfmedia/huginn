module Agents
  class PublisherTasks < Agent
    cannot_be_scheduled!

    description <<-MD
      The PublisherAgent creates an event for sending emails with La Gazette Turf to users.
    MD

    def default_options
      { date: Date.tomorrow }
    end

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
      return if Event.where(agent_id: event.agent_id).select {|e| e.payload[:date] == event.payload[:date] }.map(&:payload).uniq.count < 2
      Orchestrator::Tasks::Pipelines::Gazette.new(Date.tomorrow).launch!
    end

    def check
      create_event :payload => interpolated
    end

  end
end
