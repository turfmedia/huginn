class AgentStatus < ActiveRecord::Base
  ERROR = 'error'
  OK = 'ok'

  attr_accessible :agent_id, :monitoring_agent_id 

  def ok?
    self.status == OK
  end  

  def error!
    self.status = ERROR and self.save!
  end

  def ok!
    self.status = OK and self.save!
  end
end
