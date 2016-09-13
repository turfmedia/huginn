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
        packages: {
          required: ['js2', 'q2'],
          optional: []
        },
        html_template_id: '',
        comcenter_channel_id: '',
        comcenter_api_key: '',
      }
    end

    # check that pipeline_name and packages are given by user
    def validate_options
      errors.add(:base, 'pipeline_name is required') unless options['pipeline_name'].present?
      if options['packages'].blank?
        errors.add(:base, 'packages is required')
      else
        errors.add(:base, 'required packages can not be blank') unless options['packages']['required'].present?
      end
      
      errors.add(:base, 'html_template_id is required') unless options['html_template_id'].present?
      errors.add(:base, 'comcenter_channel_id is required') unless options['comcenter_channel_id'].present?
      errors.add(:base, 'comcenter_api_key is required') unless options['comcenter_api_key'].present?
    end

    # @return [Array] list of all available packages from options
    def packages
      required_packages + optional_packages
    end

    # @return [Array] list of required packages from options
    def required_packages
      self.options[:packages][:required] || []
    end
    # @return [Array] list of optional packages from options
    def optional_packages
      self.options[:packages][:optional] || []
    end

    def working?
      !recent_error_logs?
    end

    # Launch Orchestrator::Tasks::Pipelines::#{options.pipeline}.
    # It does nothing if either incoming_events are blank or there are not any information about another package or we have information about other packages but for another date.
    # It runs pipeline if today we get all packages from options[:packages][:required] (js2, q2 for example) from publisher api for the same date.
    # It runs pipeline if today we get all packages from options[:packages][:required] (js2, q2 for example) and given package is from optional pacakges (Erratum for example) from publisher api for the same date.
    def receive(incoming_events)
      event = incoming_events.first
      if event.blank? 
        create_event payload: {status: 'failure', date: Date.tomorrow.to_s, text: 'Given event is blank'}
        return
      end
      unless event.payload[:package_type].in?(required_packages) || event.payload[:package_type].in?(optional_packages)
        create_event payload: {status: 'failure', date: Date.tomorrow.to_s, text: "Received event is from another package #{event.inspect}. Expected this - #{packages}"}
        return 
      end
      if not dry_run?
        received_packages_before = Event.where(agent_id: event.agent_id).select do |e| 
          begin
            e.payload[:date].to_date == event.payload[:date].to_date && required_packages.include?(e.payload[:package_type])
          rescue Exception => e
            false
          end
        end.map(&:payload).uniq

        if received_packages_before.count < required_packages.count
          create_event payload: {status: 'failure', date: Date.tomorrow.to_s, text: "Were received only this packages - #{received_packages_before.inspect}; Expected this - #{packages.inspect}"}
          return
        end
      end

      date = event.payload[:date] || Date.tomorrow.to_s
      klass    = "Orchestrator::Tasks::Pipelines::#{self.options[:pipeline_name]}".constantize
      pipeline = klass.new(date, options['html_template_id'], options['comcenter_channel_id'], options['comcenter_api_key'])

      pipeline.launch!
      create_event payload: pipeline.response
    end

    def check
      create_event :payload => interpolated
    end

  end
end
