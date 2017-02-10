module Agents
  class EmailReportAgent < Agent
    include PublisherTasksConcern

    can_dry_run! #it gives run agent manually via /agents/:agent_id/dry_runs
    cannot_receive_events! 
    default_schedule "never"

    description <<-MD
      The Email Report Agent sends reports from http://reporter.services.turfmedia.com/.

      By default, the email body will contain an optional `headline`, followed by a listing of the Events' keys.

      You can specify one or more `recipients` for the email, or skip the option in order to send the email to your
      account's default email address.

      You can provide a `from` address for the email, or leave it blank to default to the value of `EMAIL_FROM_ADDRESS` (`#{ENV['EMAIL_FROM_ADDRESS']}`).

      You can provide a `content_type` for the email and specify `text/plain` or `text/html` to be sent.
      If you do not specify `content_type`, then the recipient email server will determine the correct rendering.

      Set `expected_receive_period_in_days` to the maximum amount of time that you'd expect to pass between Events being received by this Agent.

      You can provide body via http://templator.services.turfmedia.com/. For doing it you need to create you html template and specify it here with html_template_id data attribute (look at default options)
    MD

    def default_options
      {
        "data" => {
          "html_template_id" => ""
        },
        "expected_time_in_hours" => 2,
      }   
    end

    # check that file_nameare given by user
    def validate_options
      if options['data'].blank?
        errors.add(:base, 'data is required')
      else
        errors.add(:base, 'html_template_id is required') unless options['data']['html_template_id'].present?
        errors.add(:base, 'messenger_recurring_id is required') unless options['data']['messenger_recurring_id'].present?
        errors.add(:base, 'messenger_api_key is required') unless options['data']['messenger_api_key'].present?
      end
    end

    def check
      pipeline = PublisherTask::Tasks::Pipelines::Reporter::Statistics.new Date.yesterday.to_s, data: interpolated["data"]
      if pipeline.launch!
        event = create_event(payload: pipeline.response.merge(agent_name: self.name), date: Date.today.to_s)
      end
    end
  end
end
