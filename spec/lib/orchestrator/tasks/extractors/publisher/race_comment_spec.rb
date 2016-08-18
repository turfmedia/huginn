require 'rails_helper'

RSpec.describe Orchestrator::Tasks::Extractors::Publisher::RaceComment do
  let(:subject) { described_class.new race_id }
  let(:race_id) { -777 }
  let(:fake_response) do
    "{\"id\":27,\"race_id\":#{race_id},\"tip_bases\":[\"1\"],\"tip_complements\":[],\"bet_type\":\"Simple Gagnant\",\"special_type\":\"CDJ\",\"comment\":\"100% success race!!!\",\"created_at\":\"2016-08-14T13:20:28.039Z\",\"updated_at\":\"2016-08-14T13:20:28.039Z\",\"race_rc\":\"R1C1\",\"tip_set_id\":46,\"race_title\":\"Prix du Hong Kong Jockey Club\",\"meeting_id\":20294}"
  end

  before do
    allow(Net::HTTP).to receive(:get).and_return(fake_response)
  end

  context '#content' do

    let(:expected_info) do
      {"id":27,"race_id":race_id,"tip_bases":["1"],"tip_complements":[],"bet_type":"Simple Gagnant","special_type":"CDJ","comment":"100% success race!!!","created_at":"2016-08-14T13:20:28.039Z","updated_at":"2016-08-14T13:20:28.039Z","race_rc":"R1C1","tip_set_id":46,"race_title":"Prix du Hong Kong Jockey Club","meeting_id":20294}
    end

    it 'returns expected info' do
      expect(subject.content).to eq(expected_info)
    end
  end

  it '#comment returns "100% success race!!!"' do
    expect(subject.comment).to eq("100% success race!!!")
  end

end
