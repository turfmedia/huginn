module PublisherTasksConcern
  def working?
    return false if last_check_at && !checked_without_error?
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

  def last_event_at
    events.order(:created_at).first.try(:created_at)
  end


end
