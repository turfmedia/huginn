require 'rails_helper'

RSpec.describe Orchestrator::Tasks::Extractors::Publisher::JS2Package do
  let(:subject) { described_class.new '01.01.200' }

  context '#content' do
    let(:fake_response) do
      "[{\"id\":875,\"race_id\":1,\"tip_bases\":[\"10\"],\"tip_complements\":[],\"bet_type\":\"Simple Gagnant\",\"special_type\":\"CDJ\",\"comment\":\"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.\",\"race_rc\":\"R1C3\",\"tip_set_id\":486,\"race_title\":null,\"meeting_id\":null},{\"id\":878,\"race_id\":1,\"tip_bases\":[\"8\"],\"tip_complements\":[],\"bet_type\":\"Simple Gagnant\",\"special_type\":\"Reussite\",\"comment\":\"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.\",\"race_rc\":\"R1C3\",\"tip_set_id\":486,\"race_title\":null,\"meeting_id\":null},{\"id\":879,\"race_id\":1,\"tip_bases\":[\"3\"],\"tip_complements\":[],\"bet_type\":\"Simple Gagnant\",\"special_type\":\"\",\"comment\":\"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.\",\"race_rc\":\"R1C3\",\"tip_set_id\":486,\"race_title\":null,\"meeting_id\":null}]"
    end

    let(:expected_info) do
      [
        {"id":875, "race_id":1, "tip_bases":["10"], "tip_complements":[], "bet_type":"Simple Gagnant", "special_type":"CDJ", "comment":"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.", "race_rc":"R1C3", "tip_set_id":486, "race_title":nil, "meeting_id":nil},
        {"id":878, "race_id":1, "tip_bases":["8"],  "tip_complements":[], "bet_type":"Simple Gagnant", "special_type":"Reussite", "comment":"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.", "race_rc":"R1C3", "tip_set_id":486, "race_title":nil, "meeting_id":nil},
        {"id":879, "race_id":1, "tip_bases":["3"],  "tip_complements":[], "bet_type":"Simple Gagnant", "special_type":"", "comment":"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.", "race_rc":"R1C3", "tip_set_id":486, "race_title":nil, "meeting_id":nil}
      ]
    end

    before do
      allow(Net::HTTP).to receive(:get).and_return(fake_response)
    end

    it 'returns expected info about tips' do
      expect(subject.content).to eq(expected_info)
    end
  end
end
