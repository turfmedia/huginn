module Agents
  class PronosticResultsAgent < Agent
    # docs for how to create own Agent - https://github.com/cantino/huginn/wiki/Creating-a-new-agent
    can_dry_run! #it gives run agent manually via /agents/:agent_id/dry_runs
    default_schedule "never"

    description <<-MD
      The PronosticResultsAgent collects infromation about Gazette tips, get information about payout for them. And put this statistic to Google Spreadsheet
    MD

    def default_options
      { 
        date: Date.yesterday.to_s,
      }
    end

    # check that file_nameare given by user
    def validate_options
      errors.add(:base, 'file_name is required') unless options['file_name'].present?
    end

    def working?
      !recent_error_logs?
    end

    def receive(incoming_events)
      event = incoming_events.first
      check(event.payload[:date])
    end

    # Launch Orchestrator::Tasks::Pipelines::Results::Gazette pipeline.
    def check(date=nil)
      date ||= interpolated[:date]
      date ||= Date.yesterday.to_s if date.blank?
      offer_result = Orchestrator::Tasks::Pipelines::Results::Gazette.new(date, interpolated[:file_name])
  
      if offer_result.launch!
        create_event :payload => interpolated.merge(date: date, status: 'ok')
      else
        create_event :payload => interpolated.merge(date: date, status: 'failure')
      end
    end

  end
end
