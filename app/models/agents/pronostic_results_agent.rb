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
        file_name: '',
        pipeline_name: ''
      }
    end

    # check that file_nameare given by user
    def validate_options
      errors.add(:base, 'file_name is required') unless options['file_name'].present?
      errors.add(:base, 'pipeline_name is required') unless options['pipeline_name'].present?
    end

    def recent_error_logs?
      return true if last_event_at.blank? && last_error_log_at
      return true if last_event.payload[:status] == "failure"
      last_event_at && last_error_log_at && last_error_log_at > (last_event_at - 2.minutes)
    end

    def last_event
      events.order(:created_at).first
    end

    def working?
      !recent_error_logs?
    end

    def receive(incoming_events)
      event = incoming_events.first
      check(event.payload[:date])
    end

    # Launch Orchestrator::Tasks::Pipelines::Results::#{pipeline_name}.
    def check(date=nil)
      date ||= interpolated[:date].to_date if interpolated[:date].present?
      date ||= Date.yesterday if date.blank?
      date = date.to_date
      klass        = "Orchestrator::Tasks::Pipelines::Results::#{self.options[:pipeline_name]}".constantize
      
      #run pipeline for last two days
      dates = [date, date - 1.day]
      pipelines = []
      result_of_launch = dates.all? do |d|
        offer_result = klass.new(d.to_s, interpolated[:file_name])
        pipelines.push(offer_result)
        offer_result.launch!
      end

      if result_of_launch
        # if all pipelins were sucessfully finished create event with status ok
        create_event :payload => interpolated.merge(date: date.to_s, status: 'ok')
      else
        # if all pipelins were not sucessfully finished create event with status failure
        messages = pipelines.map { |pipe| pipe.response.except(:date, :status) }
        create_event :payload => interpolated.merge(date: date.to_s, status: 'failure', messages: messages)
      end
    end

  end
end
