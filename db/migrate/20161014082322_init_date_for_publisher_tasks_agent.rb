class InitDateForPublisherTasksAgent < ActiveRecord::Migration
  def up
    Agents::PublisherTasks.all.each do |agent|
      agent.events.each do |e|
        e.date = e.payload[:date]
        e.save!
      end
    end
  end

  def down
    Event.update_all date: nil
  end
end
