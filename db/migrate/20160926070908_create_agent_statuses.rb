class CreateAgentStatuses < ActiveRecord::Migration
  def change
    create_table :agent_statuses do |t|
      t.integer :monitoring_agent_id
      t.integer :agent_id
      t.string :status

      t.timestamps null: false
    end
  end
end
