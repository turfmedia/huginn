module Agents
  class AgentsStatus < Agent
    # docs for how to create own Agent - https://github.com/cantino/huginn/wiki/Creating-a-new-agent
    can_dry_run! #it gives run agent manually via /agents/:agent_id/dry_runs
    cannot_receive_events! 

    default_schedule "every_1d"

    description <<-MD
      The AgentStatus check status for all current agents. For all not-working agents will be create events which can send to another agent, for example EmailAgent.
    MD

    def default_options
      { 
        agents: 'all',
        except: [],
        expected_update_period_in_days: 1
      }
    end

    # check that agents not blank
    def validate_options
      errors.add(:base, 'agents is required') unless options['agents'].present?
    end

    # check is this agent either has error before or not
    # @param [Agent] agent with status not working
    # @return [true/false] result of new this error or not
    def new_error?(agent)
      today_events = events.where("DATE(created_at) = ?", Date.today)
      today_events = today_events.select {|e| agent.last_event_at.nil? || e.payload[:time].to_time >= agent.last_event_at }
      today_events.count.zero?
    end

    # @return [Array] list of all Agents for check
    def agents
      return @agents if @agents
      @agents = Agent.active.where.not(id: self.id)
      @agents = @agents.where(name: options[:agents].map(&:strip))     if options[:agents].present? && options[:agents] != 'all'
      @agents = @agents.where.not(name: options[:except].map(&:strip)) if options[:except].present?
      @agents
    end

    def working?
      event_created_within?(options['expected_update_period_in_days']) && !recent_error_logs?
    end

    def check
      agents.each do |agent|
        unless agent.working?
          create_event(:payload => {name: agent.name, time: Time.now}) if new_error?(agent)
        end
      end
      nil
    end

  end
end
