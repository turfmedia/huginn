class InitDateForPublisherTasksAgent < ActiveRecord::Migration
  def up
    Agents::PublisherTasks.all.each do |agent|
      agent.events.each do |e|
        e.date = e.payload[:date]
        e.save!
      end
      new_options = agent.options 
      new_options[:expected_time_in_hours] = 12
      agent.options  = new_options
      agent.save!
    end
  end

  def down
    Event.update_all date: nil
  end
end
