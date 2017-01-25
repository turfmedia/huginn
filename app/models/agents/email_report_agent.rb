module Agents
  class EmailReportAgent < Agent
    include EmailConcern

    can_dry_run! #it gives run agent manually via /agents/:agent_id/dry_runs
    cannot_receive_events! 
    default_schedule "never"

    description <<-MD
      
    MD

    def default_options
      {
        'subject' => "Report",
        'headline' => "Your notification:",
        'expected_receive_period_in_days' => "2",
        'content_type' => 'text/plain',
        "period" => "",
        "data" => {
          "html_template_id" => ""
        }

      }   
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
              body: pipeline.mail_body,
              content_type: interpolated['content_type'],
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
