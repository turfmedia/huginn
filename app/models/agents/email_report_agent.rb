module Agents
  class EmailReportAgent < Agent
    include EmailConcern

    can_dry_run! #it gives run agent manually via /agents/:agent_id/dry_runs
    cannot_receive_events! 
    default_schedule "never"

    description <<-MD
      The Email Report Agent sends reports from http://reporter.services.turfmedia.com/ for yesterday, last-7-days and last-30-dyas periods.

      You can specify the email's subject line by providing a `subject` option, which can contain Liquid formatting.  E.g.,
      you could provide `"Huginn email"` to set a simple subject, or `{{subject}}` to use the `subject` key from the incoming Event.

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
        'subject' => "Report",
        'headline' => "Your reports:",
        'expected_receive_period_in_days' => "2",
        "period" => "",
        "from" => "",
        "recipients" => [],
        "data" => {
          "html_template_id" => ""
        }

      }   
    end

    # check that file_nameare given by user
    def validate_options
      errors.add(:base, 'recipients is required') unless options['recipients'].present?
      errors.add(:base, 'from is required') unless options['from'].present?
      if options['data'].blank?
        errors.add(:base, 'data is required')
      else
        errors.add(:base, 'html_template_id is required') unless options['data']['html_template_id'].present?
      end
    end


    def working?
      received_event_without_error?
    end

    def check
      pipeline = Orchestrator::Tasks::Pipelines::Reporter::Statistics.new interpolated["period"], data: interpolated["data"]
      if res = pipeline.launch!
        recipients = interpolated['recipients']
        recipients = [recipients] unless recipients.instance_of?(Array)
        recipients.each do |recipient|
          begin
            SystemMailer.send_message(
              to: recipient,
              from: interpolated['from'],
              subject: interpolated['subject'],
              headline: interpolated['headline'],
              body: pipeline.mail_body.html_safe,
              content_type: "text/html",
            ).deliver_now
            log "Sent mail to #{recipient}"
          rescue => e
            error("Error sending mail to #{recipient}: #{e.message}")
            raise
          end
        end        
        event = create_event(:payload => interpolated)
      end
    end
  end
end
