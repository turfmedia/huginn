class RenamOfferResultsAgent < ActiveRecord::Migration
  def change
    'Agents::OfferResultsAgent'
    Agent.where(type: 'Agents::OfferResultsAgent').update_all type: "Agents::PronosticResultsAgent"
  end
end
