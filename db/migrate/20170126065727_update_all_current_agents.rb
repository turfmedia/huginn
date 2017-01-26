class UpdateAllCurrentAgents < ActiveRecord::Migration
  def change
    Agents::PublisherTasks.find_each do |agent|
      next if agent.options['data'].present?
      agent.options['data'] = {
        'messenger_recurring_id' => agent.options['comcenter_channel_id'],
        'messenger_api_key' => agent.options['comcenter_api_key'],
        'html_template_id' => agent.options['html_template_id']
      }
      agent.save!
    end
    Agents::PronosticResultsAgent.find_each do |agent|
      next if agent.options['data'].present?
      agent.options['data'] = {
        'file_name' => agent.options['file_name']
      }
      agent.save!
    end

  end
end
