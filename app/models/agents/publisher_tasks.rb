module Agents
  class PublisherTasks < Agent
    # docs for how to create own Agent - https://github.com/cantino/huginn/wiki/Creating-a-new-agent
    can_dry_run! #it gives run agent manually via /agents/:agent_id/dry_runs
    default_schedule "never"

    description <<-MD
      The PublisherAgent creates an event for sending emails with La Gazette Turf to users.
    MD

    attr_accessor :reason_not_working

    def default_options
      { 
        pipeline_name: 'Gazette',
        packages: {
          required: ['js2', 'q2'],
          optional: []
        },
        data: {
          html_template_id: '',
          messenger_recurring_id: '',
          messenger_api_key: '',
        },
        expected_time_in_hours: 12,
      }
    end

    def last_event_at
      events.order(:created_at).first.try(:created_at)
    end

    # check that pipeline_name and packages are given by user
    def validate_options
      errors.add(:base, 'pipeline_name is required') unless options['pipeline_name'].present?
      if options['packages'].blank?
        errors.add(:base, 'packages is required')
      else
        errors.add(:base, 'required packages can not be blank') unless options['packages']['required'].present?
      end
      if options['data'].blank?
        errors.add(:base, 'required data can not be blank')
      else
        errors.add(:base, 'html_template_id is required') unless options['data']['html_template_id'].present?
        errors.add(:base, 'messenger_recurring_id is required') unless options['data']['messenger_recurring_id'].present?
        errors.add(:base, 'messenger_api_key is required') unless options['data']['messenger_api_key'].present?
      end
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
      return false if events.order(:created_at).count.zero?
      if options[:expected_time_in_hours].present?
        unless event_created_within?(options[:expected_time_in_hours].to_s.gsub(/\s+/, '').to_i)
          @reason_not_working = "Last package was sent a long time ago"
          return false 
        end
      end
      if events.order(:created_at).first.payload[:status] == "ok" && !recent_error_logs?
        true
      else
        @reason_not_working = "Last run pipeline was with error"
        false
      end
    end

    def event_created_within?(time)
      if time >= 0 
        expected_time = Time.now.at_beginning_of_day + time.hours
        next_date   = Date.today # tips which should be sent today (like Turfistart JS)
      else
        time = - time
        next_date   = Date.tomorrow # tips which should be sent before 1 day (like Gazette)
        expected_time = Time.now.at_beginning_of_day + 1.day - time.hours
      end

      return true  if events.where(date: next_date).count > 0 # if package was sent before
      return false if events.where(date: next_date - 1.day).count.zero? # if more then 1 day was not any packages
      Time.now <= expected_time
    end

    # Launch PublisherTask::Tasks::Pipelines::#{options.pipeline}.
    # It does nothing if either incoming_events are blank or there are not any information about another package or we have information about other packages but for another date.
    # It runs pipeline if today we get all packages from options[:packages][:required] (js2, q2 for example) from publisher api for the same date.
    # It runs pipeline if today we get all packages from options[:packages][:required] (js2, q2 for example) and given package is from optional pacakges (Erratum for example) from publisher api for the same date.
    def receive(incoming_events)
      @processed_dates = []
      incoming_events.each do |event|
        process_event(event)
      end
    end

    def check
      event = create_event(:payload => interpolated)
      receive([event]) if dry_run?
      event
    end

    def process_event(event)
      if not dry_run?
        return false unless event.payload[:package_type].in?(required_packages) || event.payload[:package_type].in?(optional_packages)
        received_packages_before = Event.where(agent_id: event.agent_id)
        received_packages_before = received_packages_before.select do |e| 
          begin
            e.payload[:date].to_date == event.payload[:date].to_date && required_packages.include?(e.payload[:package_type])
          rescue Exception => e
            false
          end
        end
        received_packages_before = received_packages_before.map(&:payload).uniq
        return false if received_packages_before.count < required_packages.count
      end

      date = event.payload[:date] || Date.tomorrow.to_s
      
      return false if @processed_dates.include?(date)

      klass    = "PublisherTask::Tasks::Pipelines::#{self.options[:pipeline_name]}".constantize
      pipeline = klass.new(date, data: options['data'])

      result = pipeline.launch!
      if create_event(payload: pipeline.response.merge(agent_name: self.name), date: date)
        @processed_dates.push(date)
      else
        false
      end
    end

  end
end
