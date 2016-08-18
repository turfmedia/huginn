require 'rails_helper'

RSpec.describe Orchestrator::Tasks::Extractors::PronosticFacile::RacesInfo do
  let(:subject) { described_class.new 'fake_course_id' }
  let(:race_id) { -777 }
  let(:fake_response) do
    "[{\"reunion\":{\"id\":19578,\"numero\":1,\"courses\":[{\"id\":#{race_id},\"nom\":\"Prix Mendez\",\"numero\":1,\"distance\":2100,\"heure\":\"13:15\"},{\"id\":138418,\"nom\":\"Prix de l'Ile de France\",\"numero\":2,\"distance\":2100,\"heure\":\"13:15\"}],\"hippodrome\":{\"nom\":\"Maisons Laffitte\"}}},{\"reunion\":{\"id\":19580,\"numero\":3,\"courses\":[{\"id\":138435,\"nom\":\"Prix du Pont Charles-de-Gaulle\",\"numero\":1,\"distance\":2100,\"heure\":\"13:15\"},{\"id\":138436,\"nom\":\"Prix de Millau\",\"numero\":2,\"distance\":2100,\"heure\":\"13:15\"},{\"id\":138437,\"nom\":\"Prix des Batignolles\",\"numero\":3,\"distance\":2100,\"heure\":\"13:15\"}],\"hippodrome\":{\"nom\":\"Enghien Soisy\"}}}]"
  end

  let(:expected_info) do
    [
      {:reunion => 
        {
          :id=>19578, 
          :numero=>1, 
          :courses=> [
            {:id=>race_id, :nom=>"Prix Mendez", :numero=>1, :distance=>2100, :heure=>"13:15"},
            {:id=>138418, :nom=>"Prix de l'Ile de France", :numero=>2, :distance=>2100, :heure=>"13:15"}
          ], 
          :hippodrome=>{:nom=>"Maisons Laffitte"}
        }
      }, 
      {:reunion => 
        {
          :id=>19580, 
          :numero=>3, 
          :courses=>[
            {:id=>138435, :nom=>"Prix du Pont Charles-de-Gaulle", :numero=>1, :distance=>2100, :heure=>"13:15"},
            {:id=>138436, :nom=>"Prix de Millau", :numero=>2, :distance=>2100, :heure=>"13:15"},
            {:id=>138437, :nom=>"Prix des Batignolles", :numero=>3, :distance=>2100, :heure=>"13:15"}
          ], 
          :hippodrome=>{:nom=>"Enghien Soisy"}
        }
      }
    ]  
  end

  before do
    allow(Net::HTTP).to receive(:get).and_return(fake_response)
  end

  it '#content returns expected info' do
    expect(subject.content).to eq(expected_info)
  end
end
